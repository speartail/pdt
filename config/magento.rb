namespace :app do

  desc 'Create initial Magento configuration by running installer'
  task :setup_via_installer do
    run "php -f #{shared_path}/install.php -- \
      --license_agreement_accepted 'yes' \
      --locale '#{mag_locale}' \
      --timezone '#{mag_timezone}' \
      --default_currency 'USD' \
      --db_host '#{db_host}' \
      --db_name '#{db_name}' \
      --db_user '#{db_user}' \
      --db_pass '#{db_pass}' \
      --url '#{domain}' \
      --use_rewrites 'yes' \
      --use_secure '#{mag_secure}' \
      --secure_base_url '#{mag_secure_url}' \
      --use_secure_admin '#{mag_secure_admin}' \
      --admin_firstname '#{mag_admin_firstname}' \
      --admin_lastname '#{mag_admin_lastname}' \
      --admin_email '#{mag_admin_email}' \
      --admin_username '#{mag_admin_username}' \
      --admin_password '#{mag_admin_password}'"
  end

  desc 'Create initial configuration directly'
  task :setup do
  end

  desc "Make configuration symlink"
  task :symlink do
    run "ln -nfs #{release_path}/public #{appdir}"
    run "ln -nfs #{shared_path}/app/etc/local.xml #{release_path}/public/app/etc/local.xml"
    run "ln -nfs #{shared_path}/errors/local.xml #{release_path}/public/errors/local.xml"
  end

  desc "Set permissions"
  task :permissions do
    %w[ mage pear ].each do |d|
      run "test -d #{release_path}/#{d} && chmod -f 550 #{release_path}/#{d} || echo 'Directory #{d} not present yet...'"
    end
  end

  namespace :errors do

    # <config>
    #     <skin>default</skin>
    #     <report>
    #         <!-- print or email -->
    #         <action>print</action>
    #         <subject>Bellus Store Debug Information</subject>
    #         <email_address>peter@speartail.com</email_address>
    #         <!-- "trash" is handle about trace info
    #              "leave" is for store on disk
    #              "delete" is for cleaning -->
    #         <trash>leave</trash>
    #     </report>
    # </config>

    # :print or :email
    # anything else disables
    def generate_error_config(type = :print)
      xml = Builder::new
    end

    desc 'Enable error reporting via email'
    task :email do
    end

    desc 'Disable error reporting'
    task :disable do
    end

  end

end

namespace :cache do

  desc 'Create directories'
  task :setup do
    %w[ media var ].each do |d|
      run "mkdir -p #{shared_path}/data/#{d}"
      run "chmod -f 777 #{shared_path}/data/#{d}"
    end
  end

  desc 'Symlink directories'
  task :symlink do
    %w[ media var ].each { |d| run "ln -nfs #{shared_path}/data/#{d} #{release_path}/public" }
  end

  desc 'Clear cache'
  task :clear do
    %w[ cache session ].each do |f|
      run "rm -rf #{current_path}/var/#{d}/*"
    end
  end

end

namespace :db do

  desc "Change configuration stored in DB"
  task :config do ; end

end
