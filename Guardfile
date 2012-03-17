require 'active_support/inflector'

# Runs all tests
guard 'minitest' do
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
	# Will not convert while :dry_run is true. Once you're happy with your watch statements remove it
	#watch (/doc_source\/(.+\/)*(.+\.)(md|markdown)/i) { |m| "doc_source/#{m[1]}#{m[2]}#{m[3]}|doc/#{m[1]}#{m[2]}html"}
	watch (/doc_source\/(.+\/)*(.+\.)(md|markdown)/i) { |m| "doc_source/#{m[1]}#{m[2]}#{m[3]}|doc/#{m[1]}#{m[2]}html|doc_source/.template.html.erb"}
end

# Runs bundler
guard 'bundler' do
  watch('Gemfile')
end
