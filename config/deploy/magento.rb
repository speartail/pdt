namespace :app do

  desc "Create initial Magento configuration"
  task :config do
    run 'php -f #{shared_path}/install.php -- \
      --license_agreement_accepted "yes" \
      --locale "#{mag_locale}" \
      --timezone "#{mag_timezone}" \
      --default_currency "USD" \
      --db_host "#{db_host}" \
      --db_name "#{db_name}" \
      --db_user "#{db_user}" \
      --db_pass "#{db_pass}" \
      --url "#{domain}" \
      --use_rewrites "yes" \
      --use_secure "#{mag_secure}" \
      --secure_base_url "#{mag_secure_url}" \
      --use_secure_admin "#{mag_secure_admin}" \
      --admin_firstname "#{mag_admin_firstname}" \
      --admin_lastname "{mag_admin_lastname}" \
      --admin_email "{mag_admin_email}" \
      --admin_username "{mag_admin_username}" \
      --admin_password "{mag_admin_password}"'
  end

  desc "Make configuration symlink"
  task :symlink do ; end

  desc "Set permissions"
  task :permissions do
    run "chmod -f 550 #{release_path}/pear"
    run "chmod -f 550 #{release_path}/mage"
    %w[ media var ].each do |d|
      run "chmod -f 777 #{release_path}/#{d}"
    end
  end

end

namespace :db do

  desc "Change configuration stored in DB"
  task :config do ; end

end
