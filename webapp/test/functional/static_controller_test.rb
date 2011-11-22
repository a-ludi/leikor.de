require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test "accessing unknown page raises error" do
    assert_raises ActionController::RoutingError do
      get 'show', {:path => "unkown_page"}
    end
    
    assert_raises ActionController::RoutingError do
      get 'show', {:path => nil}
    end
  end

  test "accessing unknown page raises error with the path" do
    begin
      get 'show', {:path => 'unkown_page'}
    rescue ActionController::RoutingError
      assert_not_nil $!.inspect['unkown_page']
    end    
  end
end
