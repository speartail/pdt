namespace :src do

  desc 'Merge the latest PDT'
  task :pdt do
    system "b=$(git branch | grep '^\*' | cut -f2- -d ' '); git checkout pdt ; git pull ; git checkout $b; git merge pdt"
  end

end
