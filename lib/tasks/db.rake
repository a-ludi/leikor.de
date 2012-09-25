# -*- encoding : utf-8 -*-

namespace :db do
  namespace :file do
    namespace :load do
      desc 'Load a csv file line-by-line into the database using ActiveRecord. The model is inferred automagically from filename, but you can override this with MODEL.'
      task :csv, [:filename] => [:environment] do |t, args|
        require 'csv'
        
        model = (ENV['MODEL'] || File::basename(args.filename, '.csv').classify).constantize
        count = {:created => 0, :skipped => 0}
        skip_all = false
        
        begin
          CSV.foreach(args.filename, :headers => true) do |row|
            begin
              model.create! row.to_hash
            rescue ActiveRecord::RecordInvalid => invalid
              count[:skipped] += 1
              skip_all = handle_error(invalid, row) unless skip_all
            else
              count[:created] += 1
            end
          end
        rescue Interrupt => interrupt
          puts "Quitting service ..." if 'QUIT' == interrupt.to_s
        ensure
          puts "Created #{count[:created]} records in model #{model.to_s}."
          puts "Skipped #{count[:skipped]} rows of input." unless count[:skipped].zero?
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
