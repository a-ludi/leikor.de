# -*- encoding : utf-8 -*-
require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test_tested_files_checksum 'bd25db0a86cdc475ba5dda6ba0daaa13'
  
  def setup
    https! # (nearly) every action requires SSL
  end
  
  test "login required for logout" do
    assert_before_filter_applied :user_required, :destroy
  end
  
  test "new action" do
    get 'new', nil, nil, {:login => 'Hans Wurst', :referer => '/from_here_on'}
    
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
    assert_equal '/from_here_on', assigns(:referer)
    assert_equal 'Hans Wurst', assigns(:login)
  end
  
  test "new action with param referer" do
    get 'new', {:referer => '/from_here_on'}
    
    assert_equal '/from_here_on', assigns(:referer)
  end
  
  test "new action with http referer" do
    with_referer
    get 'new'
    
    assert_equal @referer, assigns(:referer)
  end
  
  test "new action with session login" do
    session[:login] = 'Hans Wurst'
    get 'new'
    
    assert_equal 'Hans Wurst', assigns(:login)
  end
  
  test "new action with logged in user" do
    get 'new', {:referer => '/from_here_on'}, with_user
    
    assert_redirected_to '/from_here_on'
  end
  
  test "create action with valid login" do
    create_with_valid_login
    
    refute_empty flash[:message]
    assert @controller.send(:logged_in?, @user)
    assert_redirected_to '/from_here_on'
  end
  
  test "create action with invalid login" do
    create_with_invalid_login
    
    assert_equal '/from_here_on', flash[:referer]
    assert flash[:wrong_login_or_password]
    assert_equal @user.login, flash[:login]
    assert_redirected_to new_session_path
  end
  
  test "unsets user_id in session on logout" do
    on_logout
    assert_nil session[:user_id]
  end
  
  test "destroy action" do
    on_logout
    assert_redirected_to '/'
  end
  
private
  def create_with_valid_login
    @user = users(:john)
    post 'create', :login => @user.login, :password => 'sekret',
        :referer => '/from_here_on'
  end

  def create_with_invalid_login
    @user = users(:john)
    post 'create', :login => @user.login, :password => 'wrong',
        :referer => '/from_here_on'
  end
  
  def on_logout(options={})
    @user = users(:john)
    unless options[:without_user]
      delete 'destroy', {}, with_user(@user)
    else
      delete 'destroy'
    end
  end
end
