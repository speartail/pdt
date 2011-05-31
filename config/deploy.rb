require 'capistrano/php'
require 'fileutils'
set :stages, %w(dev preprod prod)
set :default_stage, 'dev'
require 'capistrano/ext/multistage'
if Dir.exists?('public/wp-admin')
  set :application, 'wordpress'
  raise "You must put the theme in a directory named 'default' or create a symlink named 'default' to the relevant directory." unless File.exists?('public/wp-content/themes/default')
  load 'config/wordpress'
elsif Dir.exists?('public/app')
  set :application, 'magento'
  load 'config/magento'
else
  raise 'Neither WordPress nor Magento were found. Aborting...'
end
puts "Found application: #{application}"
load 'config/common' # must happen after the app specific loading due to :application
load 'config/project' # place all overrides here

set :copy_exclude, [ '.git' ]
set :deploy_via, :remote_cache
set :scm, :git
set :shared_children, [] # we don't need system, log, pids
set :use_sudo, false

before "deploy:setup", "config:bash", "cache:setup", "app:setup"
after  "deploy:update_code", "app:permissions", "cache:symlink", "app:symlink"
after  "db:restore", "db:config" # db:config is where we do DB contents replacements

namespace :config do

  desc 'Create BASH environment'
  task :bash do
    put %Q[umask 002\n PS1="\${debian_chroot:+($debian_chroot)}\\u@\\h:\\w$ "], File.join('/home', user, '.bash_profile')
  end
  
  desc 'Upload keys'
  task :keys do
    put File.join('keys', 'id_dsa_wordpress'), File.join('home', '.ssh', 'id_dsa') if application == 'wordpress'
    put File.join('keys', 'id_dsa_magento'), File.join('home', '.ssh', 'id_dsa') if application == 'magento'
    run "chmod 700 #{File.join('home', '.ssh')}"
    run "chmod 600 #{File.join('home', '.ssh', 'id_dsa')}"
  end
end

# TODO create database dump/restore/push/pull
namespace :db do

  namespace :local do
    task :dump do ; end
    task :restore do ; end
  end

  namespace :remote do
    task :dump do
      run %Q[mysqldump -h#{db_host} -u#{db_user} -p#{db_pass} #{db_name} | bzip2 > #{env['HOME']}/#{db_name}.sql.bz2]
    end

    task :restore do ; end
  end

  task :push do ; end
  task :pull do ; end
end

role(:app) { host }
role(:web) { host }
role(:db, :primary => true) { host }
