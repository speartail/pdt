require 'logger'
require 'ostruct'

class AppConfig

  YAML_FILE = File.expand_path((__FILE__).to_s.gsub(/rb$/, 'yml'))

  attr_reader :config

  def initialize(parms = {})
    if parms[:logger]
      @logger = parms[:logger]
      @old_level = @logger.level
    else
      @logger = Logger.new STDOUT
    end
    @logger.level = parms[:level] || Logger::INFO
    found_yaml = false
    [ parms[:file], YAML_FILE ].each do |f|
      if !found_yaml && f && File.exist?(f)
        @logger.debug "Loading YAML data from #{f}"
        begin
          @config = hashes2ostruct(YAML.load_file(f))
          found_yaml = true
        rescue ; end
      end
    end
    @logger.level = @old_level if @old_level
  end

  private
  def hashes2ostruct(object)
    return case object
    when Hash
      object = object.clone
      object.each do |key, value|
        object[key] = hashes2ostruct(value)
      end
      OpenStruct.new(object)
    when Array
      object = object.clone
      object.map! { |i| hashes2ostruct(i) }
    else
      object
    end
  end
end
