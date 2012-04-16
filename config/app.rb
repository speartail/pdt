require 'app'

class App < Configurable # :nodoc:
  config.git_revision = `git rev-parse HEAD 2>/dev/null`.to_s.strip
  config.git_short_revision = `git describe --always --tag`.to_s.strip
  config.launched_at = Time.now
  config.uptime = Proc.new { (Time.now.utc - App.launched_at).seconds }

  y = YAML.load_file('app.yml')
  config.theme_dir = y['theme_dir']
end
