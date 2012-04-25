namespace :app do

  desc "Create wp-config.php"
  task :setup do
    wp_config = ERB.new <<-EOF
<?php

/* THIS FILE IS AUTOGENERATED - DO NOT EDIT!

  DateTime: #{Time.now}

*/

define('DB_NAME',     '#{db_name}');
define('DB_USER',     '#{db_user}');
define('DB_PASSWORD', '#{db_pass}');
define('DB_HOST',     '#{db_host}');
define('DB_CHARSET',  'utf8');
define('DB_COLLATE',  '');

#{generate_keys}

$table_prefix = '#{db_prefix}';
define('WPLANG',   '#{wp_lang}');
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
  define('ABSPATH', dirname(__FILE__).'/');

require_once(ABSPATH . 'wp-settings.php');
?>
EOF
    put wp_config.result, "#{shared_path}/wp-config.php"
  end

  desc "Make configuration symlink"
  task :symlink do
    run "ln -nfs #{shared_path}/wp-config.php #{release_path}/public/wp-config.php"
    run "ln -nfs #{release_path}/public #{appdir}"
  end

  desc "Set permissions needed for install"
  task :install_permissions do
    [ ].each do |f|
      file="#{release_path}/public/#{f}"
      run "chmod -f 777 #{file}" if remote_file_exists? file
    end
  end

  desc "Set permissions"
  task :permissions do
    timthumb=File.join('public', 'wp-content', 'themes', 'default', 'scripts', 'timthumb.php')
    run("chmod -f 755 #{File.join(release_path, timthumb)}") if File.exists?(timthumb)
  end

end

namespace :cache do

  desc 'Create directories'
  task :setup do
    %w[ cache uploads ].each do |d|
      run "mkdir -p #{shared_path}/data/#{d}"
      run "chmod -f 777 #{shared_path}/data/#{d}"
    end
  end

  desc 'Symlink directories'
  task :symlink do
    run "rm -rf #{release_path}/public/wp-content/themes/default/scripts/cache"
    run "rm -rf #{release_path}/public/wp-content/uploads"
    run "ln -nfs #{shared_path}/data/cache #{release_path}/public/wp-content/themes/default/scripts/cache"
    run "ln -nfs #{shared_path}/data/uploads #{release_path}/public/wp-content/uploads"
  end

  # I don't know if we need to clear the cache directory on WordPress
  task :clear do ; end

end

namespace :content do

  def generate_page_sql(page, remote_file)
    raise NotImplementedError, 'Check magento for how this is done!'
  end

end

namespace :db do

  desc "Change configuration stored in DB"
  task :config do

    %w[home siteurl].each do |k|
      run %Q[#{mysql} -e "UPDATE #{db_prefix}options SET option_value = 'http://#{host}' WHERE option_name = '#{k}'"]
    end
    %w[template stylesheet].each do |k|
      run %Q[#{mysql} -e "UPDATE #{db_prefix}options SET option_value = 'default' WHERE option_name = '#{k}'"]
    end
  end
end

def generate_keys
  keys = ''
  %w( AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT).each do |k|
    keys <<  "define('#{k}', '#{random_chars}');\n"
  end
  return keys
end

