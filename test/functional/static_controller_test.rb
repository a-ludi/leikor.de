# -*- encoding : utf-8 -*-
require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test "skips prepare_flash_message" do
    assert_skips_before_filter :prepare_flash_message
  end
  
  test "colors page is unknown" do
    refute_includes StaticController::REGISTERED_PAGES, :colors
  end
  
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
  
  test "show action each page" do
    StaticController::REGISTERED_PAGES.each do |page, options|
      get 'show', {:path => page.to_s}
    end
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
