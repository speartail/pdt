set :branch, ""

# web host
set :host, "www.#{domain}"
set :user, ''

# db
set :db_host, ''
set :db_name, ''
set :db_user, ''
set :db_pass, ''
set :db_prefix, 'wp_'   # WordPress default
set :db_prefix, 'modx_' # MODx default

# fastcgi
# set :fastcgi, '127.0.0.1:9000'
set :fastcgi, 'unix:/var/run/php-fastcgi/php-fastcgi.socket';

set :srcdir, "/home/#{user}/shared/#{host}"
set :appdir, "/home/#{user}/#{host}"
set :deploy_to, "#{srcdir}"

# :copy for production environments we do not control
#
# set :deploy_via :remote_cache
set :deploy_via :copy
