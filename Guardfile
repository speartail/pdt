$stdout.sync = true

require './config/app_config'

EXTENSIONS = %w[ html phtml js inc php xml css gif ico png jpg ]
WEB_ROOT = "/srv/www/#{ENV['USER']}/localhost"

# MAJOR WARNING
#
# For some reason guard flat out ignores our theme directory
# so -compass and -shell are actually not working yet
#
# Compass has been disabled and is run by foreman
# Shell just prints out the file name

guard :bundler, notify: false do
  watch 'Gemfile'
end

# guard :compass, configuration_file: 'config/compass.rb' do
#   watch 'config/compass.rb'
# end

def remove_file(file)
  if File.exists?(file) && !File.directory?(file)
    rm_rf file
  end
end

guard :shell do
  puts "Guard::Shell is watching public for files to copy"
  options = { verbose: true }
  watch(%r{public/(.*)}) do |f|
    source = f[0]
    ext = File.extname(source)
    puts "#{source} was changed"
    # if File.directory?(source) || EXTENSIONS.include?(ext)
    #   if source =~ %r[^\!]
    #     puts 'a'
    #     # delete

    #   else
    #     puts 'a'
    #     # copy
    #   end
    # end
    #   target = File.join(WEB_ROOT, f[1])
    #   target_dir = File.dirname target
    #   FileUtils.rm_rf(target, options) if File.exists?(target)
    #   if File.exists?(source)
    #     FileUtils.mkdir_p(target_dir, options) unless Dir.exists?(target_dir)
    #     FileUtils.cp source, target, options
    #   end
  end
end
