require 'time'

namespace :src do

  desc 'Deploy to local folder'
  task :deploy do
    cp("public/*", "/var/www")
  end

  desc 'Merge the latest PDT'
  task :pdt do
    system "b=$(git branch | grep '^\*' | cut -f2- -d ' '); git checkout master ; git pull pdt master ; git checkout $b; git merge master"
  end

end
