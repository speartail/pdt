namespace :package do

  t = Time.now
  suffix="#{t.year}-#{t.month}-#{t.day}_#{t.hour}-#{t.min}"
  app='public'
  theme='public/wp-content/themes/default'

  namespace :theme do

    desc 'Zip theme'
    task :zip do
      system "zip -qr theme-#{suffix}.zip #{theme}"
    end

    desc 'tar theme'
    task :tar do
      system "tar -cjf theme-#{suffix}.tar.bz2 #{theme}"
    end

  end

  namespace :app do

    desc 'Zip full app'
    task :zip do
      system "zip -qr app-#{suffix}.zip #{app}"
    end

    desc 'tar app'
    task :tar do
      system "tar -cjf app-#{suffix}.tar.bz2 #{app}"
    end

  end

end

