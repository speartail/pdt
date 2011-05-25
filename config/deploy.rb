require 'capistrano/php'
require 'fileutils'
set :stages, %w(dev preprod prod)
set :default_stage, 'dev'
require 'capistrano/ext/multistage'
load 'config/common'
if Dir.exists?('../wp-admin')
  set :application, 'wordpress'
  raise "You must create a symlink named default to the theme" unless File.exists?('../wp-content/themes/default')
  load 'config/wordpress'
elsif Dir.exists?('../app')
  set :application, 'magento'
  load 'config/magento'
end
load 'config/project' # place all overrides here

raise 'Neither WordPress nor Magento were found. Aborting...' unless :application

set :copy_exclude, [ '.git' ]
set :deploy_via, :remote_cache
set :scm, :git
set :use_sudo, false

before "deploy:setup", "config:bash", "cache:setup", "app:config", "app:symlink"
after  "deploy:update_code", "config:permissions", "cache:symlink"
after  "db:restore", "db:config" # db:config is where we do DB contents replacements

namespace :config do
  desc 'Create BASH environment'
  task :bash do
    put %Q[umask 002\n PS1="\${debian_chroot:+($debian_chroot)}\\u@\\h:\w$ "], "#{ENV['HOME']}/.profile"
  end
end

# TODO create database dump/restore/push/pull
namespace :db do
  task :dump do ; end
  task :restore do ; end
  task :push do ; end
  task :pull do ; end
end

role(:app) { host }
role(:web) { host }
role(:db, :primary => true) { host }
