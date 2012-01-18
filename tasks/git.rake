namespace :git do

  desc 'check for inconsistencies'
  task :check do
    system 'git fsck'
  end

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

  desc 'Update submodules'
  task :submodules do
    system 'git submodule update --init --recursive'
  end

  desc 'Pull'
  task :pull do
    system 'git pull'
  end

  desc 'Push'
  task :push do
    system 'git push'
  end

  task :all => [ :check, :prune, :repack, :pull, :submodules, :push ]
  # task :all => [ 'git:check', 'git:prune', 'git:repack' ]

end
