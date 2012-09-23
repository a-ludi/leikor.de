# -*- encoding : utf-8 -*-
require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  test_tested_files_checksum '2726858b046eeffd4b363946b6fe85cc'

  test "before filters active" do
    [:fetch_current_user, :fetch_updated_at, :prepare_flash_message].each do |filter|
      assert_before_filter_applied filter
    end
  end
  
  test "after filters active" do
    assert_after_filter_applied :log_if_title_not_set, :test_method
    assert_after_filter_not_applied :log_if_title_not_set, :stylesheet
    assert_after_filter_not_applied :log_if_title_not_set, :pictures
  end
  
  test "save_updated_at" do
    @saved_time = call_method :save_updated_at
    
    assert_equal @saved_time.to_s.to_time, AppData['updated_at']
  end
  
  test "fetch_updated_at always returns Time" do
    call_method :fetch_updated_at
    
    assert_kind_of Time, assigns(:updated_at)
  end  
  
  test "fetch_updated_at returns correct Time" do
    @saved_time = call_method :save_updated_at
    call_method :fetch_updated_at
    
    assert_equal @saved_time.to_s.to_time, assigns(:updated_at)
  end
  
  test "prepare_flash_message" do
    call_method :prepare_flash_message
    
    assert_includes flash, :message
    assert_kind_of FlashMessage, flash[:message]
  end
  
  test "prepare_flash_message with already set message" do
    call_method :prepare_flash_message, [], :flash => {:message => 42}
    
    assert_includes flash, :message
    refute_kind_of FlashMessage, flash[:message]
  end
  
  test "login_user!" do
    @user = users(:john)
    call_method :login_user!, [@user]
    
    assert_equal @user.id, session[:user_id]
    assert_equal @user.login, session[:login]
    assert_equal @user, assigns(:current_user)
  end
  
  test "logout_user!" do
    https!
    call_method :logout_user!, [], :session => with_user
    
    assert_empty flash[:message]
    assert_nil session[:user_id]
    assert_nil assigns(:current_user)
  end
  
  test "not logged_in?" do
  	@logged_in = call_method :logged_in?
  	
  	refute @logged_in
  end
  
  test "logged_in? employee check" do
    https!
  	@logged_in_employee = call_method :logged_in?, [Employee], :session => with_user(:john)
  	@logged_in_customer = call_method :logged_in?, [Customer], :session => with_user(:john)
  	
  	assert @logged_in_employee
  	refute @logged_in_customer
  end
  
  test "logged_in? customer check" do
    https!
  	@logged_in_employee = call_method :logged_in?, [Employee], :session => with_user(:moritz)
  	@logged_in_customer = call_method :logged_in?, [Customer], :session => with_user(:moritz)
  	
  	refute @logged_in_employee
  	assert @logged_in_customer
  end
  
  test "logged_in? user check" do
    session = with_user
    https!
  	@logged_in = call_method :logged_in?, [@user], :session => session
  	
  	assert @logged_in
  end
  
  test "fetch_current_user" do
    https!
    call_method :fetch_current_user, [], :session => with_user
    
    assert_equal @user, assigns(:current_user)
  end
  
  test "user_required passes" do
    https!
    @passed = call_method :user_required, [], :session => with_user
    
    assert @passed
  end
  
  test "user_required fails" do
    @passed = call_method :user_required, [], :render => false
    
    refute @passed
    assert_present flash[:message]
  end
  
  test "employee_required passes" do
    https!
    @passed = call_method :employee_required, [], :session => with_user
    
    assert @passed
  end
  
  test "employee_required fails" do
    https!
    @passed = call_method :employee_required, [], :render => false, :session => with_user(:moritz)
    
    refute @passed
    assert_present flash[:message]
  end
  
  test "fetch_categories without params" do
    @passed = call_method :fetch_categories
    
    assert @passed
    assert_respond_to assigns(:categories), :each
    refute_empty assigns(:categories)
    assigns(:categories).each do |category|
      refute_kind_of Subcategory, category
      assert_kind_of Category, category
    end
  end
  
  test "fetch_categories with category" do
    @category = categories(:super)
    @passed = call_method :fetch_categories, [], :params => {:category => @category.to_param}
    
    assert @passed
    assert_respond_to assigns(:categories), :each
    assert_equal @category, assigns(:category)
  end
  
  test "fetch_categories with subcategory" do
    @subcategory = categories(:sub1)
    @category = @subcategory.category
    @passed = call_method :fetch_categories, [], :params => {:category => @category.to_param,
        :subcategory => @subcategory.to_param}
    
    assert @passed
    assert_respond_to assigns(:categories), :each
    assert_equal @category, assigns(:category)
    assert_equal @subcategory, assigns(:subcategory)
  end
  
  test "not_found with defaults" do
    @proc = Proc.new {@controller.send :not_found}
    assert_raises ActionController::RoutingError do
      @proc.call
    end
    
    begin
      @proc.call
    rescue ActionController::RoutingError => e
      refute_empty e.to_s
    end
  end
  
  test "not_found with custom message and logger" do
    @message = 'Special Message #23196700797360814'
    @proc = Proc.new {@controller.send :not_found, @message, :log => true}
    assert_raises ActionController::RoutingError do
      @proc.call
    end
    
    begin
      @proc.call
    rescue ActionController::RoutingError => e
      assert_equal @message, e.to_s
    end
    
    assert_logs do
      begin
        @proc.call
      rescue ActionController::RoutingError
      end
    end
  end
  
  test "log_if_title_not_set logs and passes" do
    assert_logs do
      @passed = @controller.send :log_if_title_not_set
    end
    assert @passed
  end
  
  test "log_if_title_not_set doesn't log but passes" do
    get :set_title
    refute_logs do
      @passed = @controller.send :log_if_title_not_set
    end
    assert @passed
  end
  
  test "escape_like_pattern" do
    @pattern = 'This is a _pattern_ with 0% alcohol'
    @expected_pattern = 'This is a \\_pattern\\_ with 0\\% alcohol'
    @escaped_pattern = call_method :escape_like_pattern, [@pattern]
    
    assert_equal @expected_pattern, @escaped_pattern
  end
  
  test "set_up_user_required_message with html response" do
    @passed = call_method :user_required, [], :render => false
    
    refute @passed
    assert_present flash[:message]
    assert_redirected_to new_session_path
  end
  
  test "set_up_user_required_message with js response" do
    @passed = call_method :user_required, [], :render => false, :xhr => true
    
    refute @passed
    assert_present flash[:message]
    assert_template :partial => 'layouts/_push_message', :count => 1
  end
  
  test "set_up_user_required_message conserves flash referer" do
    @referer = '/from/here/on'
    @passed = call_method :user_required, [], :render => false, :flash => {:referer => @referer}
    
    refute @passed
    assert_equal @referer, flash[:referer]
  end
  
  test "set_up_user_required_message conserves request path" do
    @passed = call_method :user_required, [], :render => false
    
    refute @passed
    assert_equal '/test/application/test_method', flash[:referer]
  end
end
