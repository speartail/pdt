require 'rake'
require 'rake/clean'

Dir.glob('tasks/*.rake').each { |r| import r }

CLEAN.include('*~')

task :default =>  [ :clean, 'tidy:all' ]
