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
end

private

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
