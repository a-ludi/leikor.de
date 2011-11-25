ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  include UtilityHelper
  include AssertionsHelper
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  fixtures :all

  def with_user(user=:john, session={})
    user = users(user) if user.is_a? Symbol
    session.merge(:user_id => user.id)
  end
end
