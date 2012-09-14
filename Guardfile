require 'active_support/inflector'

# Restart test-server
guard 'spork', :wait => 60 do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('test/test_helper.rb') { :test_unit }
  watch(%r{lib/(utility|tests|assertions)_helper.rb})
end

# Runs all tests
guard 'minitest', :drb => true do
  # tests
  watch(%r|^test/(.*)_test\.rb|)
  
  # fixtures
  watch(%r|^test/fixtures/(.*).yml|) {|m| "test/unit/#{m[1].singularize}_test.rb"}
  
  # test_helper.rb
  watch(%r|^test/test_helper\.rb|) { "test" }
  
  # models
  watch(%r|^app/models/(.*).rb|) {|m| "test/unit/#{m[1]}_test.rb"}
  
  # controllers
  watch(%r|^app/controllers/(.*).rb|) {|m| "test/functional/#{m[1]}_test.rb"}
  
  # helpers
  watch(%r|^app/helpers/(.*)_helper.rb|) {|m| "test/functional/#{m[1]}_controller_test.rb"}
end

# Builds Markdown doc as HTML
guard 'markdown', :convert_on_start => true do
  watch (/(.+\/)*doc_source\/(.+\/)*(.+\.)(md|markdown)/i) { |m| "#{m[1]}doc_source/#{m[2]}#{m[3]}#{m[4]}|#{m[1]}doc/#{m[2]}#{m[3]}html|#{m[1]}doc_source/.template.html.erb"}
end

# Runs bundler
guard 'bundler' do
  watch('Gemfile')
end
