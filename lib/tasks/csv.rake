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
  
  namespace :dump do
    desc 'Print data in a csv format suitable for importing into PlentyMarkets.'
    task :plentymarkets => [:environment] do |t, args|
      require 'csv'
      
      csv_data = CSV.generate(
        :headers => TRANSLATE_TO_PLENTY_MARKETS_FIELD.keys,
        :write_headers => true,
        :col_sep => "\t"
      ) do |csv|
        Article.all.each do |article|
          csv << TRANSLATE_TO_PLENTY_MARKETS_FIELD.map do |key, method_or_proc_or_value|
            value = case method_or_proc_or_value
              when Symbol then
                article.send(method_or_proc_or_value)
              when Proc then
                method_or_proc_or_value.call(article)
              else
                method_or_proc_or_value
            end
            
            # Avoid usage of characters, that require quotes
            value.to_s.tr("\t\n\r", "   ")
                      .gsub '"', "&#x22;"
          end
        end
      end
      
      # Remove quoted empty fields
      puts csv_data.gsub('""', '')
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


  UNIT_TO_MM = {:mm => 1, :cm => 10, :dm => 100, :m => 1000}
  
  def dimension_in_mm dimension
    lambda do |article|
      unless article.send(dimension).nil?
        article.send(dimension) * UNIT_TO_MM[article.unit.to_sym]
      else
        0
      end
    end
  end

  def price_amount i
    lambda do |article|
      if i < article.prices.length
        article.prices[i].amount
      else
        0
      end
    end
  end

  def price_minimum_count i
    lambda do |article|
      if i < article.prices.length
        article.prices[i].minimum_count
      else
        0
      end
    end
  end

  TRANSLATE_TO_PLENTY_MARKETS_FIELD = {
    'ItemImageURL' => lambda {|a| a.picture.url},
    'ItemPosition' => :ord,
    'ItemTextName' => :name,
    'ItemTextDescription' => :description,
    'ItemTextMeta' => :description,
    'ItemTextLang' => 'de',
    'ItemNo' => :article_number, # FIXME Punkt ist nicht erlaubt
    'PriceHeight' => dimension_in_mm(:height),
    'PriceLength' => dimension_in_mm(:depth),
    'PriceWidth' => dimension_in_mm(:width),
    'Price6' => price_amount(0),
    'Price7' => price_amount(1),
    'Price8' => price_amount(2),
    'Price9' => price_amount(3),
    'Price10' => price_amount(4),
    'Price11' => price_amount(5),
    'PriceDiscountLevel6' => price_minimum_count(0),
    'PriceDiscountLevel7' => price_minimum_count(1),
    'PriceDiscountLevel8' => price_minimum_count(2),
    'PriceDiscountLevel9' => price_minimum_count(3),
    'PriceDiscountLevel10' => price_minimum_count(4),
    'PriceDiscountLevel11' => price_minimum_count(5),
    'CategoryLevel1Name' => lambda {|a| a.subcategory.name},
    'CategoryLevel2Name' => lambda {|a| a.subcategory.category.name}
  }

