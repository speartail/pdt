require 'securerandom'
require './config/app_config'

@app_config = AppConfig.new

EMAIL = 'support@speartail.com'

set :mag_locale , 'en_US'
set :mag_timezone, 'Asia/Singapore'
set :mag_currency, 'SGD'
set :mag_secure, 'no'
set :mag_secure_url, ''
set :mag_secure_admin, 'no'
set :mag_admin_firstname, 'Admin'
set :mag_admin_lastname, 'User - DISABLE ME'
set :mag_admin_username, 'admin'
# we only set mag_admin_password on install
# set :mag_admin_password, PASSWORD
set :mag_admin_email, EMAIL

set :wp_debug, false
set :wp_lang, ''

if @app_config && @app_config.config && @app_config.config.repos
  set :repository, @app_config.config.repos
else
  set(:repository, "git@github.com:speartail/#{application}.git") if [ 'magento', 'wordpress' ].include?(application)
end

puts "Set initial password: #{PASSWORD}"
