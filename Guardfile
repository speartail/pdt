require './config/app_config'

WEB_ROOT = "/srv/www/#{ENV['USER']}/localhost"

guard 'bundler', :notify => false do
  watch 'Gemfile'
end

# does not work
# guard 'compass', :configuration_file => 'config/compass.rb' do
#   watch 'config/compass.rb'
# end

# guard 'shell' do
#   puts "Guard::Shell is watching public for files to copy"
#   options = { :verbose => true }
#   watch(%r{public\/(.*\.(html|phtml|php|xml|css|png|jpg))$}) do |f|
#     source = f[0]
#     target = File.join(WEB_ROOT, f[1])
#     target_dir = File.dirname target
#     FileUtils.rm_rf(target, options) if File.exists?(target)
#     if File.exists?(source)
#       FileUtils.mkdir_p(target_dir, options) unless Dir.exists?(target_dir)
#       FileUtils.cp source, target, options
#     end
#   end
# end
