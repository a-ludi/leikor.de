require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
  require 'test_help'
  class Test::Unit::TestCase
    self.use_transactional_fixtures = true
    self.use_instantiated_fixtures  = false
  end
end

Spork.each_run do
  class Test::Unit::TestCase
    fixtures :all

    include UtilityHelper
    include AssertionsHelper
    include TestHelper
  end
end
