# -*- encoding : utf-8 -*-
require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
  require 'test_help'

  class ActiveSupport::TestCase
    self.use_transactional_fixtures = true
    self.use_instantiated_fixtures  = false
    
    fixtures :all

    include UtilityHelper
  end
end

Spork.each_run do
  class ActiveSupport::TestCase
    include TestsHelper
    include AssertionsHelper
  end
end
