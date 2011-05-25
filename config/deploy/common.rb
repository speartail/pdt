set :mag_locale , 'en_us'
set :mag_timezone, 'Asia/Singapore'
set :mag_currency, 'SGD'
set :mag_secure, 'no'
set :mag_secure_url, ''
set :mag_secure_admin, 'no'
set :mag_admin_firstname, 'Admin'
set :mag_admin_lastname, 'User'
set :mag_admin_username, 'support@northwind.sg'
set :mag_admin_password, 'super_shazza'

set :wp_debug, false
set :wp_lang, ''

if is_mag
  set :repository,  "git@github.com:nwt/magento.git"
elsif is_wp
  set :repository,  "git@github.com:nwt/wordpress.git"
end
