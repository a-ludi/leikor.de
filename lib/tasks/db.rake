# -*- encoding : utf-8 -*-

namespace :db do
  desc 'Create some records for test purposes'
  task :init_records => %w(environment db:schema:load) do
    do_process 'Creating webmaster account' do
      Employee.create! do |wm|
        wm.login = 'webmaster'
        wm.password = 'wertzu'
        wm.name = 'Hans Meyer'
        wm.primary_email_address = 'webmaster@leikor.de'
        wm.notes = 'I am the **master** of the web!'
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
  end
end

def do_process description
  print description + ' ... '
  yield
  puts 'done.'
end
