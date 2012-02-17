MAGENTO_VERSION="1.6.1.0"
WP_VERSION="latest"

namespace :download do

  desc 'Download latest Magento version'
  task :magento do
    system "wget -c 'http://www.magentocommerce.com/getmagento/#{MAGENTO_VERSION}/magento-#{MAGENTO_VERSION}.tar.bz2'"
  end

  desc 'Download latest Wordpress version'
  task :wordpress do
    system "wget -c 'http://wordpress.org/#{WP_VERSION}.tar.gz'"
  end

  desc 'Download latest timthumb version'
  task :timthumb do
    system "wget -c http://timthumb.googlecode.com/svn/trunk/timthumb.php"
  end

end
