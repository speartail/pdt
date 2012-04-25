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

# this is critical as first deploy will otherwise fail with a 'Host key verification failed'
default_run_options[:pty] = true
# also allow ForwardAgent in $HOME/.ssh/config
ssh_options[:forward_agent] = true

before 'app:setup', 'app:prepare'
before 'deploy:setup', 'config:bash', 'config:tmux', 'config:mysql', 'cache:setup'
after  'deploy:update_code', 'app:permissions', 'cache:symlink', 'cache:clear', 'app:symlink'
after  'app:symlink', 'db:seed'
after  'db:restore', 'db:config' # db:config is where we do DB contents replacements

def random_chars(length = 64)
  return rand(36**length).to_s(36)
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

  desc 'Load CMS pages'
  task :pages do
    root_dir = File.join(Dir.pwd, 'data', 'pages')
    begin
      pages = YAML.load_file(File.join(root_dir, 'pages.yml'))
      pages.each do |page|
        run %Q[#{mysql} -e "#{generate_create_page_sql(page)}"]
      end
    rescue
      puts 'Unable to load pages.yml. Continuing...'
    end
    Dir.glob(File.join(root_dir, '*.html')).each do |p|
      page = File.basename(p).gsub('.html', '')
      file = "/tmp/#{random_chars 12}_#{page}"
      upload p, file
      run %Q[#{mysql} -e "#{generate_page_sql(page, file)}"]
    end
  end

end

# TODO create database dump/restore
namespace :db do

  namespace :local do
    task :dump do ; end
    task :restore do ; end
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

  desc 'Dump the remote database'
  task :dump, :roles => [ :db ] do
    run %Q[mysqldump -h#{db_host} -u#{db_user} #{db_name} > /home/#{user}/#{db_name}.sql]
  end

  desc 'Compress the remote database'
  task :compress, :roles => [ :db ] do
    run %Q[bzip2 /home/#{user}/#{db_name}.sql]
  end

  task :restore, :roles => [ :db ] do ; end

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

role(:app) { host }
role(:web) { host }
role(:db, :primary => true) { host }

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end
