# Require any additional compass plugins here.

# Set this to the root of your project when deployed:
http_path = "/"

@base = 'public'
if Dir.exists? File.join(@base, 'skin')
  # magento
  @base = File.join @base, 'skin', 'frontend', 'default'
elsif Dir.exists? File.join(@base, 'wp-content')
  # wordpress
  @base = File.join @base, 'wp-content', 'themes', 'default'
elsif Dir.exists? File.join
else
  puts 'Unable to find project'
end

[ 'css', 'CSS', 'stylesheets' ].each do |d|
  dir = File.join @base, d
  css_dir = dir if Dir.exists? dir
end
sass_dir = File.join @base, 'sass'
images_dir = File.join @base, 'images'
javascripts_dir = File.join @base, 'javascripts'

# You can select your preferred output style here (can be overridden via the command line):
# output_style = :expanded or :nested or :compact or :compressed

# To enable relative paths to assets via compass helper functions. Uncomment:
# relative_assets = true

# To disable debugging comments that display the original location of your selectors. Uncomment:
# line_comments = false

# If you prefer the indented syntax, you might want to regenerate this
# project again passing --syntax sass, or you can uncomment this:
# preferred_syntax = :sass
# and then run:
# sass-convert -R --from scss --to sass sass scss && rm -rf sass && mv scss sass
