require 'fileutils'

SOURCE_FILES=%w[ css inc ini html js php phtml scss tpl xml ]

namespace :tidy do

  desc "all cleanup jobs"
  task :all => [ :eol, :perms, :empty_dirs ]

  desc 'line endings to LF'
  task :eol do
    SOURCE_FILES.each { |s| Dir.glob(["public/*.{#{s}}", "public/**/*.{#{s}}"]).each { |f| system "fromdos #{f}" } }
  end

  desc 'permissions to 644'
  task :perms do
    system "find public -type f -print0 | xargs -0 chmod 644"
    system "find public -type d -print0 | xargs -0 chmod 755"
  end

  desc 'clean white space'
  task :white do
    SOURCE_FILES.each { |s| Dir.glob("**/*.{#{s}}").each { |f| system "sed -i 's/[ \t]\+$//g' #{f}" } }
  end
  
  desc 'create .gitignore to allow adding empty dirs'
  task :empty_dirs do
    Dir.glob(["public","**/**"]).each { |f| FileUtils.touch(File.join(f, ".gitignore")) if File.directory?(f) }
  end

end
