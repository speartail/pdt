require 'fileutils'

SOURCE_FILES=%w[php js css inc ini tpl]

namespace :clean do

  desc "all cleanup jobs"
  task :all => [ :backup, :eol, :perms, :empty_dirs ]

  desc "remove backup files"
  task :backup do
    system "find . -name '*~' -delete"
  end

  desc 'line endings to LF'
  task :eol do
    SOURCE_FILES.each { |s| Dir.glob("**/*.{#{s}}").each { |f| system "fromdos #{f}" } }
  end

  desc 'permissions to 644'
  task :perms do
    system "find . -type f -print0 | xargs -0 chmod 644"
    system "find . -type d -print0 | xargs -0 chmod 755"
  end

  desc 'clean white space'
  task :white do
    SOURCE_FILES.each { |s| Dir.glob("**/*.{#{s}}").each { |f| system "sed -i 's/[ \t]\+$//g' #{f}" } }
  end
  
  desc 'create .gitignore to allow adding empty dirs'
  task :empty_dirs do
    Dir.glob(["**","**/**"]).each { |f| FileUtils.touch(File.join(f, ".gitignore")) if File.directory?(f) }
  end

end
