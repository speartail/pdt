VERSION="latest"

namespace :wordpress do

  desc 'Download latest Wordpress version'
  task :download do
    system "wget -c 'http://wordpress.org/#{VERSION}.tar.gz'"
  end

end
