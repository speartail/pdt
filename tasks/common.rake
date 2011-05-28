MAGENTO_VERSION="1.5.1.0"
WP_VERSION="latest"

namespace :magento do

  desc 'Download latest Magento version'
  task :download do
    system "wget -c 'http://www.magentocommerce.com/getmagento/#{MAGENTO_VERSION}/magento-#{MAGENTO_VERSION}.tar.bz2'"
  end

end

namespace :wordpress do

  desc 'Download latest Wordpress version'
  task :download do
    system "wget -c 'http://wordpress.org/#{WP_VERSION}.tar.gz'"
  end

end
