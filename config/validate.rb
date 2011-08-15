namespace :validate do

  require 'w3c_validators'
  include W3CValidators

  desc "Validate HTML"
  task :html do
    @validator = MarkupValidator.new
    print_validation_errors @validator.validate_uri("http://#{host}")
  end

  desc "Validate CSS"
  task :css do 
    @validator = CSSValidator.new
    print_validation_errors @validator.validate_uri("http://#{host}")
  end

end

def print_validation_errors(result)
  if results.errors.length > 0
    results.errors.each do |err|
      puts err.to_s
    end
  else
    puts 'Valid!'
  end
end
