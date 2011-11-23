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
  
  test "stylesheet is set on valid pages" do
    page = StaticController::REGISTERED_PAGES.first
    get 'show', {:path => page[0]}
    assert_equal page[1][:stylesheets], assigns(:stylesheets)
  end
  
  test "response is success on valid pages" do
    page = StaticController::REGISTERED_PAGES.first
    get 'show', {:path => page[0]}
    assert_response :success
  end
  
  test "correct template is rendered on valid pages" do
    page = StaticController::REGISTERED_PAGES.first
    get 'show', {:path => page[0]}
    assert_template page[0]
  end
end
