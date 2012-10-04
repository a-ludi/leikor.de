# -*- encoding : utf-8 -*-

namespace :db do
  namespace :file do
    namespace :load do
      desc 'Load a csv file line-by-line into the database using ActiveRecord. The model is inferred automagically from filename, but you can override this with MODEL. Skipped rows are written to SKIPPED.'
      task :csv, [:filename] => [:environment] do |t, args|
        require 'csv'
        require 'open-uri'
        
        model = (ENV['MODEL'] || model_from_file_name(args.filename)).constantize
        records = {:created => [], :skipped => []}
        skip_all = false
        
        begin
          data = open(args.filename) {|f| f.read}
          CSV.parse(data, :headers => true) do |row|
            begin
              record = model.create! row.to_hash
            rescue ActiveRecord::RecordInvalid => invalid
              records[:skipped] << row
              skip_all = handle_error(invalid, row) unless skip_all
            else
              records[:created] << record
            end
          end
        rescue Interrupt => interrupt
          if 'QUIT' == interrupt.to_s
            puts "Quitting service ..."
          else
            raise interrupt
          end
        ensure
          puts "Created #{records[:created].count} records in model #{model.to_s}."
          puts "Skipped #{records[:skipped].count} rows of input." unless records[:skipped].empty?
        end
        
        if not records[:skipped].empty? and not ENV['SKIPPED'].blank?
          filename = ENV['SKIPPED']
          
          begin
            handle_file_already_exists(filename) if File::exists? filename
          rescue Interrupt => interrupt
            if 'QUIT' == interrupt.to_s
              puts "Aborted. Nothing written."
            else
              raise interrupt
            end
          else
            CSV.open(filename, 'wb') do |file|
              file << records[:skipped].first.headers
              records[:skipped].each {|record| file << record }
            end
            
            puts "Written skipped rows to `#{filename}`"
          end
        end
      end
    end
  end
  
  desc 'Create some records for test purposes'
  task :init_records => %w(environment db:abort_if_pending_migrations) do
    do_process 'Creating employees' do
      Employee.create! do |wm|
        wm.login = 'webmaster'
        wm.password = 'wertzu'
        wm.name = 'Hans Meyer'
        wm.primary_email_address = 'webmaster@leikor.de'
        wm.notes = 'I am the **master** of the web!'
      end
      
      Employee.create! do |wm|
        wm.login = 'anon'
        wm.password = 'wertzu'
        wm.name = 'Anon Ymus'
        wm.primary_email_address = 'webmaster@leikor.de'
        wm.notes = "* Bilder einpflegen\n* Neue Artikelbeschreibungen schreiben"
      end
    end
    
    do_process 'Creating customers' do
      Customer.create! do |wm|
        wm.login = 'meyer-und-co'
        wm.password = 'wertzu'
        wm.name = 'Meyer & Co.'
        wm.primary_email_address = 'webmaster@leikor.de'
        wm.notes = 'Das ist die _durchschnittsdeutsche Firma_ schlechthin.'
      end
    end
    
    do_process 'Creating categories' do
      schoenes_aus_holz = Category.create! :name => 'Schönes aus Holz', :ord => 1
      schoenes_aus_holz.subcategories.create! :name => 'Elefanten', :ord => 1
      schoenes_aus_holz.subcategories.create! :name => 'Eulen', :ord => 2
      Category.create! :name => 'Spiele', :ord => 1
    end
    
    do_process 'Creating articles' do
      subcategory = Subcategory.first
      subcategory.articles.create! do |art|
        art.article_number = '10112.1'
        art.name = 'Elefantenhinter S'
        art.description = 'Diese knuffigen Hintern peppen jeden langweiligen Wohnzimmerschrank auf!'
        art.price = 999.99
        art.ord = 1
      end
      subcategory.articles.create! do |art|
        art.article_number = '10110.21'
        art.name = 'Elefantenfamilie (kompakt)'
        art.description = 'In Eintracht und Frieden ziehen diese Elefanten durch die Savanne.'
        art.price = 13.37
        art.ord = 2
      end
    end
    
    do_process 'Creating blog posts' do
      Employee.first.owned_blog_posts.create! do |bp|
        bp.title = 'Hello World!'
        bp.body = 'Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor
          incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
          exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat. Quis aute iure
          reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur
          sint obcaecat cupiditat non proident, sunt in culpa qui officia deserunt mollit anim id
          est laborum.'
        bp.editor = bp.author
        bp.public_id = bp.title.url_safe
      end
    end
  end
end

private

  def do_process description
    print description + ' ... '
    yield
    puts 'done.'
  end
  
  def model_from_file_name(filename)
    model_name = filename.split('/').last
    model_name[/^(.*)\.csv(\?.*)?$/, 1].classify
  end

  def handle_error(error, row)
    puts 'Encountered errors'
    puts error.record.errors.full_messages.map{|e| '  ' + e}
    puts 'while processing input line'
    puts '  ' + row.to_s
    print 'How do you want to proceed? [SKIP,all,quit] '
    done = false
    while not done
      answer = $stdin.gets.strip.downcase
      done = true
      
      if 'skip'.start_with? answer
        return false
      elsif 'all'.start_with? answer
        return true
      elsif 'quit'.start_with? answer
        raise Interrupt, 'QUIT'
      else
        done = false
      end
    end
  end
  
  def handle_file_already_exists(filename)
    puts "The file `#{filename}` already exists."
    print "Overwrite existing file? [yes,NO] "
    
    done = false
    while not done
      answer = $stdin.gets.strip.downcase
      done = true
      
      if 'yes'.start_with? answer
        return
      elsif 'no'.start_with? answer
        raise Interrupt, 'QUIT'
      else
        done = false
      end
    end
  end
