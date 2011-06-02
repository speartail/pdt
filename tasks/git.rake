namespace :git do

  desc 'prune the repository'
  task :prune do
    system 'git prune'
    system 'git prune-packed'
  end

  desc 'recompress the repository'
  task :repack do
    system 'git gc --aggressive'
    system 'git repack -d -a --window=50 --depth=50 -f'
  end

  task :all => [ 'git:prune', 'git:repack' ]

end
