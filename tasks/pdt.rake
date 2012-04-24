namespace :pdt do

  desc 'Resync'
  task :resync do
    system 'git checkout master'
    system 'git pull --all'
    system 'git merge pdt/master'
  end

end
