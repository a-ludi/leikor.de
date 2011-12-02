require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test "show action with unknown page" do
    assert_raises ActionController::RoutingError do
      get 'show', {:path => :unkown_page}
    end
    
    assert_raises ActionController::RoutingError do
      get 'show', {:path => nil}
    end
    
    begin
      get 'show', {:path => :unkown_page}
    rescue ActionController::RoutingError => e
      assert_not_nil e.inspect['unkown_page']
    end
  end

  test "show action" do
    page = StaticController::REGISTERED_PAGES.first
    get 'show', {:path => page[0]}
    
    assert_equal page[1][:stylesheets], assigns(:stylesheets)
    assert_equal page[1][:name], assigns(:title)
    assert_equal page[1], assigns(:page)
    assert_response :success
    assert_template page[0].to_s
  end
end
