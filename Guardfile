require './config/app_config'

BASE = 'public'
WEB_ROOT = "/srv/www/#{ENV['USER']}/localhost"

guard 'bundler', :notify => false do
  watch('Gemfile')
end

guard 'compass', :configuration_file => 'config/compass.rb' do
  watch 'config/compass.rb'
  watch(/^#{BASE}\/(.*)\.s[ac]ss/)
end

guard 'shell' do
  options = { :verbose => true }
  watch(/^#{BASE}\/(.*)/) do |f|
    source = f[0]
    target = File.join(WEB_ROOT, source.gsub(/^#{BASE}\//, ''))
    # we don't want to copy s[ac]ss files
    unless File.extname(source) == '.scss'
      FileUtils.rm_rf(target, options) if File.exists?(target)
      if File.exists?(source)
        if File.directory? source
          FileUtils.mkdir_p target, options
        else
          FileUtils.cp source, target, options
        end
      end
    end
  end
end
