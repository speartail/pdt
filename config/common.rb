EMAIL = 'support@speartail.com'

set :mag_locale , 'en_us'
set :mag_timezone, 'Asia/Singapore'
set :mag_currency, 'SGD'
set :mag_secure, 'no'
set :mag_secure_url, ''
set :mag_secure_admin, 'no'
set :mag_admin_firstname, 'Admin'
set :mag_admin_lastname, 'User'
set :mag_admin_username, EMAIL
set :mag_admin_password, 'super_shazza'
set :mag_admin_email, EMAIL

set :wp_debug, false
set :wp_lang, ''

set(:repository, "git@github.com:nwt/#{application}.git") if [ 'magento', 'wordpress' ].include?(application)
