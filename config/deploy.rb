require 'capistrano/php'
require 'fileutils'
set :stages, %w(local dev preprod prod)
set :default_stage, 'dev'
require 'capistrano/ext/multistage'
if Dir.exists?('public/wp-admin')
  set :application, 'wordpress'
  raise "You must put the theme in a directory named 'default' or create a symlink named 'default' to the relevant directory." unless File.exists?('public/wp-content/themes/default')
  load 'config/wordpress'
elsif Dir.exists?('public/app')
  set :application, 'magento'
  load 'config/magento'
elsif Dir.exists?('public/connectors')
  set :application, 'modx'
  load 'config/modx'
else
  raise 'Neither WordPress, Magento nor MODx were found. Aborting...'
end
puts "Found application: #{application}"
load 'config/common' # must happen after the app specific loading due to :application
load 'config/project' # place all overrides here

set :copy_exclude, [ '.git' ]
set :deploy_via, :remote_cache
set :scm, :git
set :shared_children, [] # we don't need system, log, pids
set :use_sudo, false

before "deploy:setup", "config:bash", "config:keys", "cache:setup", "app:setup"
after  "deploy:update_code", "app:permissions", "cache:symlink", "app:symlink"
after  "db:restore", "db:config" # db:config is where we do DB contents replacements

namespace :config do

  desc 'Create BASH environment'
  task :bash do
    put %q|
umask 002
PS1="\${debian_chroot:+($debian_chroot)}\\u@\\h:\\w$ "
if [ -z "$STY" ]; then
    exec screen -ARR
fi
    |, File.join('/home', user, '.bash_profile')
  end
  
  desc 'Upload keys'
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

  desc 'Zip up the remote app'
  task :dump do
    run %Q[tar -cjhf /home/#{user}/#{project}_app.tar.bz2 #{appdir}]
  end

  desc 'Download the remotely dumped app'
  task :pull do
    download "/home/#{user}/#{project}_app.tar.bz2", "#{project}_app.tar.bz2", :once => true
  end

end

# TODO create database dump/restore
namespace :db do

  namespace :local do
    task :dump do ; end
    task :restore do ; end
  end

  namespace :remote do

    desc 'Dump the remote database'
    task :dump, :roles => [ :db ] do
      run %Q[mysqldump -h#{db_host} -u#{db_user} #{db_name} | bzip2 > /home/#{user}/#{db_name}.sql.bz2]
    end

    task :restore, :roles => [ :db ] do ; end

  end

  desc 'Download the remote database'
  task :pull do
    download "/home/#{user}/#{db_name}.sql.bz2", "#{db_name}.sql.bz2", :once => true
  end

  desc 'Upload the database'
  task :push do
    upload "#{db_name}.sql.bz2", "/home/#{user}/#{db_name}.sql.bz2", :once => true
  end

  desc 'Dump and download database in one go'
  task :get do
    transaction do
      top.db.remote.dump
      top.db.pull
    end
  end

end

role(:app) { host }
role(:web) { host }
role(:db, :primary => true) { host }
