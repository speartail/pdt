namespace :app do

  desc "Create initial Magento configuration"
  task :setup do
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
    run "ln -nfs #{shared_path}/data/media #{release_path}/media"
    run "ln -nfs #{shared_path}/data/var #{release_path}/var"
end

namespace :db do

  desc "Change configuration stored in DB"
  task :config do ; end

end
