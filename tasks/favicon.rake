require 'favicon_maker'

namespace :favicon do

  desc 'Generate favicons'
  task :generate do
    options = {
      :root_dir => '.',
      :input_dir => File.join('public', 'images'),
      :output_dir => File.join('public', 'images'),
    }
    FaviconMaker::Generator.create_versions(options) do |filepath|
      puts "Generated favicon: #{filepath}"
    end
  end

end
