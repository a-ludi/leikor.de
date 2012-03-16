require 'active_support/inflector'

guard 'minitest' do
  # tests
  watch(%r|^test/(.*)_test\.rb|)
  
  # fixtures
  watch(%r|^test/fixtures/(.*).yml|) {|m| "test/unit/#{m[1].singularize}_test.rb"}
  
  # test_helper.rb
  watch(%r|^test/test_helper\.rb|)    { "test" }
  
  # models
  watch(%r|^app/models/(.*).rb|) {|m| "test/unit/#{m[1]}_test.rb"}
  
  # controllers
  watch(%r|^app/controllers/(.*).rb|) {|m| "test/functional/#{m[1]}_test.rb"}
  
  # helpers
  watch(%r|^app/helpers/(.*)_helper.rb|) {|m| "test/functional/#{m[1]}_controller_test.rb"}
end

guard 'markdown', :convert_on_start => true, :dry_run => true do  
	# See README for info on the watch statement below
	# Will not convert while :dry_run is true. Once you're happy with your watch statements remove it
	watch (/source_dir\/(.+\/)*(.+\.)(md|markdown)/i) { |m| "source_dir/#{m[1]}#{m[2]}#{m[3]}|output_dir/#{m[1]}#{m[2]}html"}
	watch (/source_dir\/(.+\/)*(.+\.)(md|markdown)/i) { |m| "source_dir/#{m[1]}#{m[2]}#{m[3]}|output_dir/#{m[1]}#{m[2]}html|optional_template.html.erb"}
end

guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end
