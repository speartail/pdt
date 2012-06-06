namespace :links do

  namespace :emails do

    desc 'Update all GIF links to PNG'
    task :gif_to_png do
      EMAIL_DIR = File.join('data/emails')
      if Dir.exists? EMAIL_DIR
        Dir.glob(File.join(EMAIL_DIR, '**', '*.html')).each do |f|
          system "sed -i 's/logo_email.gif/logo_email.png/g' #{f}"
        end
      end

    end

  end

end
