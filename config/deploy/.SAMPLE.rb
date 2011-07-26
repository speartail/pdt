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

set :srcdir, "/home/#{user}/shared/#{host}"
set :appdir, "/home/#{user}/#{host}"
set :deploy_to, "#{srcdir}"
