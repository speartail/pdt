guard 'bundler', :notify => false do
  watch('Gemfile')
end

guard 'compass', :configuration_file => 'config/compass.rb' do
  watch(/^public\/(.*)\.s[ac]ss/)
end
