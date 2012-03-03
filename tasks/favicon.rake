namespace :favicon do

  desc 'Create favicons'
  task :create_versions do
    options = {
      :root_dir => '.',
      :input_dir => File.join('public', 'images'),
      :output_dir => File.join('public', 'images'),
    }
    FaviconMaker::Generator.create_versions(options) do |filepath|
      puts "Created favicon: #{filepath}"
    end
  end

end
