require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test "show action with unknown page" do
    assert_raises ActionController::RoutingError do
      get 'show', {:path => 'unkown_page'}
    end
    
    assert_raises ActionController::RoutingError do
      get 'show', {:path => nil}
    end
    
    begin
      get 'show', {:path => 'unkown_page'}
    rescue ActionController::RoutingError => e
      assert_not_nil e.inspect['unkown_page']
    end
  end

  test "show action" do
    page = StaticController::REGISTERED_PAGES.first
    get 'show', {:path => page[0].to_s}
    
    assert_equal page[1][:stylesheets], assigns(:stylesheets)
    assert_equal page[1][:name], assigns(:title)
    assert_equal page[1], assigns(:page)
    assert_response :success
    assert_template page[0].to_s
  end
  
  test "show action with welcome" do
    page = StaticController::REGISTERED_PAGES.first
    get 'show', {:path => page[0].to_s, :welcome => true}
    
    assert_nil assigns(:title)
  end
  
  test "stylesheet action" do
    stylesheet = 'layout.css'
    get 'stylesheet', :path => stylesheet
    
    assert_response :success
    assert_template stylesheet
  end
  
  test "stylesheet action fails" do
    stylesheet = 'not_existing.css'
    assert_raises ActionController::RoutingError do
      get 'stylesheet', :path => stylesheet
    end
  end
end
