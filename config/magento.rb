namespace :app do

  desc 'Create initial Magento configuration by running installer'
  task :setup do
    PASSWORD = SecureRandom.hex(5)
    run "rm -f #{shared_path}/app/etc/local.xml"
    run "php -f #{release_path}/public/install.php -- \
      --license_agreement_accepted 'yes' \
      --locale '#{mag_locale}' \
      --timezone '#{mag_timezone}' \
      --default_currency 'USD' \
      --db_host '#{db_host}' \
      --db_name '#{db_name}' \
      --db_user '#{db_user}' \
      --db_pass '#{db_pass}' \
      --url 'http://#{domain}' \
      --use_rewrites 'yes' \
      --use_secure '#{mag_secure}' \
      --secure_base_url '#{mag_secure_url}' \
      --use_secure_admin '#{mag_secure_admin}' \
      --admin_firstname '#{mag_admin_firstname}' \
      --admin_lastname '#{mag_admin_lastname}' \
      --admin_email '#{mag_admin_email}' \
      --admin_username '#{mag_admin_username}' \
      --admin_password '#{PASSWORD}'"
    run "mkdir -p #{shared_path}/app/etc"
    run "mkdir -p #{shared_path}/errors"
    run "cp #{release_path}/public/app/etc/local.xml #{shared_path}/app/etc"
    run %Q[ #{mysql} -e "delete from adminnotification_inbox;" ]
    puts "Set initial password: #{PASSWORD}"
  end

  desc "Make configuration symlink"
  task :symlink do
    run "ln -nfs #{release_path}/public #{appdir}"
    run "ln -nfs #{shared_path}/app/etc/local.xml #{release_path}/public/app/etc/local.xml"
    run "ln -nfs #{shared_path}/errors/local.xml #{release_path}/public/errors/local.xml"
    run "ln -nfs #{release_path}/public/lib/Zend/Locale/Data/en_US.xml #{release_path}/public/lib/Zend/Locale/Data/en_us.xml"
  end

  desc "Set permissions"
  task :permissions do
    %w[ mage pear ].each do |f|
      file="#{release_path}/public/#{f}"
      run "chmod -f 550 #{file}" if remote_file_exists? file
    end
    [ 'var/locks' ].each do |f|
      file="#{shared_path}/data/#{f}"
      run "chmod -Rf 777 #{file}" if remote_file_exists? file
    end
  end

  namespace :errors do

    # :print or :email
    # anything else disables
    def generate_error_config(type = :print)
      require 'builder'
      xml = Builder::XmlMarkup.new
      xml.comment! "Autogenerated at #{Time.now} - please do not manually edit"
      xml.config do |c|
        c.skin 'default'
        c.report do |r|
          case type
          when :print
            r.action 'print'
          when :email
            r.action 'email'
          else
            r.action 'none' # I actually don't know if this works or if we simply shouldn't write anything
          end
          r.subject 'Magento Store Debug Information'
          r.email_address 'notify@speartail.com'
          # trash can be leave or delete
          r.trash 'leave'
        end
      end
      xml
    end

    desc 'Enable error reporting via email'
    task :email do
      put generate_error_config(:email), "#{shared_path}/errors/local.xml"
    end

    desc 'Enable error reporting online'
    task :online do
      put generate_error_config(:print), "#{shared_path}/errors/local.xml"
    end

    desc 'Disable error reporting'
    task :disable do
      run "rm -f #{shared_path}/errors/local.xml"
    end

  end

  namespace :hints do
    desc 'Enable hints'
    task :enable do
      run %Q[ #{mysql} -e "update core_config_data set value = 1 where path = 'dev/debug/template_hints';"]
    end

    desc 'Disable hints'
    task :disable do
      run %Q[ #{mysql} -e "update core_config_data set value = 0 where path = 'dev/debug/template_hints';"]
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
    %w[ media var ].each { |d| run "rm -rf #{release_path}/public/#{d} ; ln -nfs #{shared_path}/data/#{d} #{release_path}/public" }
  end

  desc 'Clear cache'
  task :clear do
    # we used to clear session too but it really shouldn't be needed
    %w[ cache ].each do |d|
      run "rm -rf #{shared_path}/data/var/#{d}/*"
    end
    # run %Q[ php -f #{release_path}/public/shell/indexer.php reindexall ] if remote_file_exists?("#{release_path}/public/shell/indexer.php")
  end

end

namespace :content do

  TIME_FORMAT = '%Y-%m-%d %H:%M:%S'

  def generate_item_sql(table, item, file)
    sql=%Q[
      UPDATE #{table}
      SET
        content = '$(cat #{file})',
        update_time = '#{Time.now.strftime TIME_FORMAT}'
      WHERE
        identifier = '#{item}';]

    return sql
  end

  def generate_page_sql(page, remote_file)
    generate_item_sql 'cms_page', page, remote_file
  end

  def generate_block_sql(block, remote_file)
    generate_item_sql 'cms_block', block, remote_file
  end

  def generate_page_meta_sql(page_meta)
    def hash_to_sql(h)
      sql = ''
      h.each_pair do |k,v|
        sql="#{k} = '#{v}', #{sql}" unless [ 'identifier', 'page_id' ].include? k
      end
      sql.to_s.gsub(/,\s+$/, '')
    end
    t = Time.now.strftime TIME_FORMAT
    sql=%Q[
      UPDATE cms_page
      SET
        #{hash_to_sql page_meta},
        creation_time = '#{t}',
        update_time = '#{t}'
      WHERE
        identifier = '#{page_meta['identifier']}' ;]

    return sql
  end

end

namespace :db do

  desc "Change configuration stored in DB"
  task :config do
    %w[ secure unsecure ].each do |s|
      sql = "update core_config_data set value = \"http://#{domain}/\" where path = \"web/#{s}/base_url\";"
      run "echo '#{sql}' | #{mysql}"
    end
  end

end

namespace :mode do

  desc 'Set server to development mode'
  task :dev do
    top.app.errors.online
    # run "cd #{current_path}/public ; zf disable mage-core-cache"
    top.cache.clear
  end

  desc 'Set server to production mode'
  task :prod do
    top.app.errors.disable
    # run "cd #{current_path}/public ; zf enable mage-core-cache"
    top.cache.clear
  end
end

# do not call this user as it clashes with the user variable
namespace :users do

  namespace :admin do
    desc "Reset admin password to 'password'"
    task :reset do
      run %Q[#{mysql} -e "UPDATE admin_user SET password=CONCAT(MD5('qXpassword'), ':qX') WHERE username = 'admin';"]
    end
  end
end
