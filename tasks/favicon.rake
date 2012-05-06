require 'favicon_maker'

require './config/app_config'
@app_config = AppConfig.new

namespace :favicon do

  desc 'Generate favicons'
  task :generate do
    options = {
      :root_dir => '.',
      :input_dir => @app_config.config.theme_root,
      :output_dir => @app_config.config.theme_root
    }
    FaviconMaker::Generator.create_versions(options) do |filepath|
      puts "Generated favicon: #{filepath}"
    end
  end

end
