VERSION="1.5.1.0"

namespace :magento do

  desc 'Download latest Magento version'
  task :download do
    system "wget -c 'http://www.magentocommerce.com/getmagento/#{VERSION}/magento-#{VERSION}.tar.bz2'"
  end

end
