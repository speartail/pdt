# Require any additional compass plugins here.
#
# Other requires
require './config/app_config'

@app_config = AppConfig.new

# Set this to the root of your project when deployed:
http_path = "/"

found_css = false
css = File.join @app_config.config.theme_root, 'css'
[ 'css', 'CSS', 'stylesheets' ].each do |d|
  dir = File.join @app_config.config.theme_root, d
  if Dir.exists?(dir) && !found_css
    found_css = true
    css = dir
  end
end
css_dir = css
sass_dir = File.join @app_config.config.theme_root, 'sass'
images_dir = File.join @app_config.config.theme_root, 'images'
javascripts_dir = File.join @app_config.config.theme_root, 'javascripts'

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
