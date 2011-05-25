require 'capistrano/php'
require 'FileUtils'
require 'deploy/common' # load common settings
if Dir.exists?('../wp-admin')
  is_wp=true
  require 'deploy/wordpress'
elsif Dir.exists?('../app')
  is_mag=true
  require 'deploy/magento'
end
require 'deploy/project' # place all overrides here
require 'capistrano/ext/multistage'

raise 'Neither WordPress nor Magento were found. Aborting...' unless is_wp || is_mag

set :copy_exclude, [ '.git' ]
set :default_stage, 'dev'
set :deploy_via, :remote_cache
set :scm, :git
set :stages, %w(dev test prod)
set :use_sudo, false

before "deploy:setup", "config:bash", "app:config", "app:symlink"
after  "deploy:update_code", "config:permissions"
after  "db:restore", "db:config" # db:config is where we do DB contents replacements

namespace :config do
  desc 'Create BASH environment'
  task :bash do
    put %Q[umask 002\n PS1="\${debian_chroot:+($debian_chroot)}\\u@\\h:\w$ "], "#{ENV['HOME']}/.profile"
  end
end

namespace :db do
  task :dump do ; end
  task :restore do ; end
end
