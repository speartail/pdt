require 'logger'
require 'ostruct'
require 'yaml'

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
      @logger.debug "Trying to load file: #{f}"
      if !found_yaml && f && File.exist?(f)
        @logger.info "Loading YAML data from #{f}"
        begin
          @config = hashes2ostruct(YAML.load_file(f))
          found_yaml = true
        rescue Exception => e
          @logger.error "Unable to load #{f}: #{e.message}"
          exit 1
        end
      end
    end
    base = 'public'
    if Dir.exists? File.join(base, 'skin')
      @config.project_type = :magento
      @config.theme_root = File.join base, 'skin', 'frontend', 'default', @config.theme_dir
    elsif Dir.exists? File.join(base, 'wp-content')
      @config.project_type = :wordpress
      @config.theme_root = File.join base, 'wp-content', 'themes', @config.theme_dir
    elsif Dir.exists? File.join(base, 'some_random_modx_path')
      @config.project_type = :modx
      @config.theme_root = File.join base, 'gibblygob', @config.theme_dir
    else
      raise NotImplementedError, 'I do not have support for this project type'
    end
    @logger.level = @old_level if @old_level
  end

  def to_s
    @config.to_s
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
