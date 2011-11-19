ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  include UtilityHelper
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def assert_errors_on(obj, options={})
    if options[:on].is_a? Symbol
      options[:message] = "expected errors on #{obj}.#{options[:on]}" unless options[:message]
      obj.valid?
      assert obj.errors.on(options[:on]), options[:message]
    else
      options[:message] = "expected errors on #{obj}" unless options[:message]
      assert !obj.valid?, options[:message]
    end
  end
  
  def assert_creates_record_from(record_class, options={})
    message = "record of class #{record_class} could not be generated from #{options.inspect}"
    assert record_class.create(options).save, message
  end
  
  def assert_includes(obj, *keys)
    includes_all = true
    keys.each do |key|
      includes_all &= obj.include? key
    end
    message = "#{obj} does not include all of #{keys.inspect}"
    assert includes_all, message
  end
  
  def assert_exact_match(pattern, string, options={})
    options[:message] = "#{string} does not exactly match #{pattern}" unless options[:message]
    assert string =~ UtilityHelper::delimited(pattern), options[:message]
  end
  
  def assert_items_unique(collection, options={}, &proc)
    if block_given?
      collection.map! &proc
    end
  
    options[:message] = "#{collection} is empty" unless options[:message]
    assert !collection.empty?, options[:message] if options[:not_empty]
    
    options[:message] = "non-unique items in: #{collection.inspect}" unless options[:message]
    assert_equal collection.length, collection.uniq.length, options[:message]
  end
end
