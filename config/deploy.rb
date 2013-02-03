require 'capistrano/php'
require 'fileutils'
require 'yaml'
set :stages, %w(local dev preprod prod)
set :default_stage, 'local'
require 'capistrano/ext/multistage'

require './config/app_config'
@app_config = AppConfig.new
set :application, @app_config.config.project_type.to_s
load "config/#{application}"
puts "Found application: #{application}"

load 'config/common' # must happen after the app specific loading due to :application
load 'config/project' # place all overrides here

set :copy_exclude, [ '.git' ]
set :deploy_via, :remote_cache
set :scm, :git
set :shared_children, [] # we don't need system, log, pids
set :use_sudo, false
set :git_enable_submodules, 1

# this is critical as first deploy will otherwise fail with a 'Host key verification failed'
default_run_options[:pty] = true
# also allow ForwardAgent in $HOME/.ssh/config
ssh_options[:forward_agent] = true

before 'app:setup', 'app:prepare', 'shared:setup'
before 'deploy:setup', 'config:bash', 'config:tmux', 'config:mysql', 'cache:setup'
after  'deploy:update_code', 'app:permissions', 'cache:symlink', 'cache:clear', 'app:symlink'
after  'deploy:create_symlink', 'content:emails', 'db:seed' #, 'content:pages' # too dangerous when in production
after  'db:restore', 'db:config' # db:config is where we do DB contents replacements

def random_chars(length = 64)
  return rand(36**length).to_s(36)
end

def quote(str)
  str.gsub(/\\|'/) { |c| "\\#{c}" }
end

def upload_and_run_sql(local_file)
  rem = "/tmp/#{random_chars 8}_#{File.basename local_file}"
  upload local_file, rem
  run "#{mysql} < #{rem}" if remote_file_exists?(rem)
end

namespace :config do

  desc 'Create BASH environment'
  task :bash do
    put %q|
umask 002
PS1="\${debian_chroot:+($debian_chroot)}\\u@\\h:\\w$ "
if [ -z "$STY" ]; then
    # exec tmux attach
    exec screen -ARR
fi
    |, File.join('/home', user, '.bash_profile')
  end

  desc 'Generate the various config pieces from templates'
  task :generate, roles: :web do
    run "mkdir -p #{shared_path}/config/#{stage}"
    Dir.glob(File.join(File.dirname(__FILE__), '..', 'templates', '*.erb')).each do |t|
      template = File.read(t)
      buffer   = ERB.new(template).result(binding)
      put buffer, "#{shared_path}/config/#{stage}/#{File.basename(t, '.erb')}"
    end
  end

  desc 'Configure tmux'
  task :tmux do
    upload('~/.tmux.conf', '~/.tmux.conf') if File.exists?('~/.tmux.conf')
  end

  desc 'Upload keys - DEPRECATED - use ForwardAgent instead'
  task :keys do
    upload(File.join('keys', 'id_dsa'), File.join('/home', user, '.ssh', 'id_dsa'))
    run "chmod 700 #{File.join('/home', user, '.ssh')}"
    run "chmod 600 #{File.join('/home', user, '.ssh', 'id_dsa')}"
  end

  desc 'MySQL configuration'
  task :mysql do
    put %Q|
[client]
host=#{db_host}
user=#{db_user}
password=#{db_pass}
    |, File.join('/home', user, '.my.cnf')
    run "chmod 600 #{File.join('/home', user, '.my.cnf')}"
  end

end

namespace :app do

  desc 'Prepare for deployment'
  task :prepare do
    run "rm -rf #{appdir}"
  end

  desc 'Zip up the remote app'
  task :dump do
    run %Q[tar -cjhf /home/#{user}/#{project}_app.tar.bz2 #{appdir}]
  end

  desc 'Download the remotely dumped app'
  task :pull do
    download "/home/#{user}/#{project}_app.tar.bz2", "#{project}_app.tar.bz2", :once => true
  end

end

namespace :content do

  desc 'Update CMS meta data - you MIGHT need to resave all pages manually!'
  task :meta do
    root_dir = File.join(Dir.pwd, 'data', 'pages')
    begin
      pages = YAML.load_file(File.join(root_dir, 'pages.yml'))
      pages.each do |page|
        run %Q[#{mysql} -e "#{generate_page_meta_sql(page)}"]
      end
    rescue
      puts 'Unable to load pages.yml. Continuing...'
    end
    puts 'WARNING! You MIGHT have to resave all pages for this to work!'
  end

  desc 'Load CMS pages'
  task :pages do
    root_dir = File.join(Dir.pwd, 'data', 'pages')
    Dir.glob(File.join(root_dir, '*.html')).each do |p|
      page = File.basename(p).gsub('.html', '')
      file = "/tmp/#{random_chars 12}_#{page}"
      upload p, file
      run %Q[#{mysql} -e "#{generate_page_sql(page, file)}"]
    end
  end

  desc 'Load CMS blocks (if supported)'
  task :blocks do
    root_dir = File.join(Dir.pwd, 'data', 'blocks')
    Dir.glob(File.join(root_dir, '*.html')).each do |b|
      block = File.basename(b).gsub('.html', '')
      file = "/tmp/#{random_chars 12}_#{block}"
      upload block, file
      run %Q[#{mysql} -e "#{generate_block_sql(block, file)}"]
    end
  end

end

# TODO create database dump/restore
namespace :db do

  desc 'Create the DB'
  task :create do
    puts 'ERROR, this does not work as the user has not been created yet'
    puts 'NOTE, this does not work unless db_host == localhost'
    [
      "create database #{db_name};",
      "create user '#{db_user}'@'#{db_host}' identified by '#{db_pass}';",
      "grant all on #{db_name}.* to '#{db_user}'@'#{db_host}';",
      "flush privileges;"
    ].each do |sql|
      run "echo \"#{sql}\" | #{mysql}"
    end
  end

  desc "Seed the data stored in 'db/seed/*.sql - happens automatically on deploy'"
  task :seed do
    Dir.glob(File.join(Dir.pwd, 'data', 'db', 'seed', '*.sql')).each do |f|
      upload_and_run_sql f
    end
  end

  desc "Load the data stored in 'db/*.sql'"
  task :load_sql do
    Dir.glob(File.join(Dir.pwd, 'data', 'db', '*.sql')).each do |f|
      upload_and_run_sql f
    end
  end

  desc 'Drop the database - DESTRUCTIVE'
  task :drop, :roles => [ :db ] do
    puts 'This is a highly DESTRUCTIVE operation'
    if force.to_s.upcase == 'YES'
      sql = "drop database #{db_name};"
      run "echo #{sql} | #{mysql}"
    else
      puts "Please pass '-s force=yes' to actually do it"
    end
  end

  desc 'Dump the remote database'
  task :dump, :roles => [ :db ] do
    run %Q[mysqldump -h#{db_host} -u#{db_user} #{db_name} > /home/#{user}/#{db_name}.sql]
  end

  desc 'Compress the remote database'
  task :compress, :roles => [ :db ] do
    run %Q[bzip2 /home/#{user}/#{db_name}.sql]
  end

  desc 'Load a DB from a backup file - DESTRUCTIVE'
  task :restore, :roles => [ :db ] do
    puts 'This is a highly DESTRUCTIVE operation'
    if force.to_s.upcase == 'YES'
      transaction do
        file = "/tmp/#{random_chars 12}_db.sql"
        upload db_file, file
        top.db.drop
        [
          "create database #{db_name};",
        ].each do |sql|
            run "echo \"#{sql}\" | #{mysql}"
          end
          run "#{mysql} #{db_name} < #{file}"
      end
    else
      puts "Please pass '-s force=yes' to actually do it"
    end
  end

  desc 'Download the remote database'
  task :pull do
    download "/home/#{user}/#{db_name}.sql.bz2", "#{db_name}.sql.bz2", :once => true
  end

  desc 'Upload the database'
  task :push do
    upload "#{db_name}.sql.bz2", "/home/#{user}/#{db_name}.sql.bz2", :once => true
  end

  desc 'Change domain in extract'
  task :change_domain do
    run %Q[sed -i 's/#{dev_domain}/#{domain}/g' /home/#{user}/#{db_name}.sql]
  end

  desc 'Publish dump file in public folder'
  task :publish do
    raise NotImplementedError, 'TODO - add support for publishing dump for http download'
  end

  desc 'Dump and download database in one go'
  task :get do
    transaction do
      top.db.dump
      top.db.compress
      top.db.pull
    end
  end

end

desc 'Generate robots.txt'
task :robots do
  put "Sitemap: http://#{domain}/sitemap.xml", "#{current_path}/robots.txt"
end

role(:app) { host }
role(:web) { host }
role(:db, :primary => true) { host }

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end
