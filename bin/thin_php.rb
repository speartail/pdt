#!/usr/bin/env ruby
# encoding: UTF-8
$stdout.sync = true

# $-w = true

BASE_PATH = File.expand_path(File.dirname(__FILE__))
SRC_PATH = File.join(BASE_PATH, 'public')

SERVER_PORT = '3000'
SERVER_HOST = '0.0.0.0'

require 'awesome_print'
require 'optparse'
require 'thin'
require 'rack-legacy'
require 'rack/legacy/cgi'
require 'rack/legacy/php'

# Handler to sort of simulate Apache's DirectoryIndex directive
class DirectoryIndex
  def initialize(app, root=Dir.pwd, files=[])
    @app = app
    @root = root
    @files = files
  end

  def call(env)
    if env['PATH_INFO'] =~ /\/$/
      path = File.join(@root, Rack::Utils.unescape(env['PATH_INFO']))
      if File.directory?(path)
        @files.each do |file|
          if File.exists?(File.join(path, file))
            env['PATH_INFO'] = env['PATH_INFO'] + file
            break
          end
        end
      end
    end
    @app.call(env)
  end
end

options = {}
options[:ip] = SERVER_HOST
options[:port] = SERVER_PORT

OptionParser.new do|opts|
  opts.banner = "Usage: #{File.basename __FILE__} [options]"

  opts.on('-i', '--ip IP', 'IP address to listen on' ) do |ip|
    options[:ip] = ip
  end

  opts.on('-p', '--port PORT', 'Port to listen on' ) do |port|
    options[:port] = port
  end

  opts.on('-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end.parse!

app = Rack::Builder.new do
  use DirectoryIndex, SRC_PATH,
    ['index.php', 'index.html', 'index.htm', 'default.htm']

  use Rack::ShowExceptions
  use Rack::Legacy::Php, SRC_PATH
  use Rack::Legacy::Cgi, SRC_PATH

  run Rack::Directory.new(SRC_PATH)
end

Rack::Handler::Thin.run(app, { :Host => options[:ip], :Port => options[:port] })
