# -*- encoding : utf-8 -*-
require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  test "before filters active" do
    [:fetch_logged_in_user, :fetch_updated_at, :prepare_flash_message].each do |filter|
      assert_before_filter_applied filter, @controller
    end
  end
  
  test "after filters active" do
    [:log_if_title_not_set].each do |filter|
      assert_after_filter_applied filter, @controller
    end
  end
  
  test "save_updated_at" do
    call_method :save_updated_at
    
    assert_equal @result.to_s.to_time, AppData['updated_at']
  end
  
  test "fetch_updated_at always returns Time" do
    call_method :fetch_updated_at
    
    assert_kind_of Time, assigns(:updated_at)
  end  
  
  test "fetch_updated_at returns correct Time" do
    call_method :save_updated_at
    @saved_time = @result.to_s.to_time
    
    call_method :fetch_updated_at
    assert_equal @saved_time, assigns(:updated_at)
  end
  
  test "login_user!" do
    skip "TODO hier geht's weiter :-)"
  end
  
#  test "user_logged_in?" do
#  	skip "FIXME deprecated"
#    get 'index', {}, with_user
#    
#    assert @controller.send :user_logged_in?
#  end
#  
#  test "superuser_logged_in?" do
#  	skip "FIXME deprecated"
#    assert_respond_to @controller, :superuser_logged_in?
#  end
#  
#  #FIXME
#  test "login_required with format html and referer present" do
#    skip "FIXME buggy"
#    @request.env['HTTP_REFERER'] = '/from_here_on'
#    get 'new' # calls login_required
#    
#    assert_equal '/from_here_on', flash[:referer]
#    assert_not_empty flash[:message]
#    assert_redirected_to new_session_path
#  end
#  
#  test "login_required format js and no referer present" do
#    get 'new', :format => 'js' # calls login_required
#    
#    assert_nil flash[:referer]
#    assert_template 'layouts/_push_message'
#  end
#  
#  test "login_required with login" do
#    get 'new', {}, with_user
#    
#    assert_template 'new'
#  end
#  
#  test "fetch_categories without params" do
#    get 'index' # calls fetch_categories
#    
#    assert_not_empty assigns(:categories)
#    assert_equal [categories(:super_fst), categories(:super)], assigns(:categories)
#  end
#  
#  test "fetch_categories with category" do
#    @category = categories(:super)
#    get 'index', @category.url_hash
#    
#    assert_not_empty assigns(:categories)
#    assert_equal @category, assigns(:category)
#  end
#  
#  test "fetch_categories with subcategory" do
#    @subcategory = categories(:sub1)
#    get 'index', @subcategory.url_hash
#    
#    assert_not_empty assigns(:categories)
#    assert_equal @subcategory.category, assigns(:category)
#    assert_equal @subcategory, assigns(:subcategory)
#  end
#  
#  test "log_if_title_not_set logs and passes" do
#    assert_logs do
#      assert @controller.send :log_if_title_not_set
#    end
#  end
end
