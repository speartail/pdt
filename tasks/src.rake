require 'time'

namespace :src do

  desc 'Merge the latest PDT'
  task :pdt do
    system "b=$(git branch | grep '^\*' | cut -f2- -d ' '); git checkout pdt ; git pull ; git checkout $b; git merge pdt"
  end

  namespace :theme do

  desc 'Zip theme'
  task :zip do
    t = Time.now
    system "zip -r theme-#{t.year}-#{t.month}-#{t.day}_#{t.hour}-#{t.min}.zip public/wp-content/themes/default"
  end

end
