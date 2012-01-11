require 'rake'
require 'rake/clean'

Dir.glob('tasks/*.rake').each { |r| import r }

CLEAN.include('*~')

namespace :git do

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

end

task :default =>  [ :clean, 'tidy:all' ]
