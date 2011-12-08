# -*- encoding : utf-8 -*-
require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "login required for logout" do
    assert_before_filter_applied :login_required, :destroy
  end
  
  test "new action" do
    get 'new', :referer => '/from_here_on'
    
    assert_respond_to assigns(:stylesheets), :each
    assert_non_empty_kind_of String, assigns(:title)
    assert_equal '/from_here_on', assigns(:referer)
  end
  
  test "new action with http referer" do
    with_referer
    get 'new'
    
    assert_equal @referer, assigns(:referer)
  end
  
  test "create action with valid login" do
    create_with_valid_login
    
    assert_equal @user.id, session[:user_id]
    assert_not_nil flash[:message]
    assert_redirected_to '/from_here_on'
  end
  
  test "create action with invalid login" do
    create_with_invalid_login
    
    assert_equal '/from_here_on', assigns(:referer)
    assert flash[:wrong_login_or_password]
    assert_equal @user.login, assigns(:login)
    assert_redirected_to new_session_path
  end
  
  test "unsets user_id in session on logout" do
    on_logout
    assert_nil session[:user_id]
  end
  
  test "destroy action with referer" do
    with_referer
    on_logout
    
    assert_nil assigns(:current_user)
    assert_not_nil flash[:message]
    assert_redirected_to @referer
  end
  
  test "destroy action without referer" do
    on_logout
    
    assert_redirected_to '/'
  end
  
private
  def create_with_valid_login
    @user = users(:john)
    post 'create', :login => @user.login, :password => 'sekret', :referer => '/from_here_on'
  end

  def create_with_invalid_login
    @user = users(:john)
    post 'create', :login => @user.login, :password => 'wrong', :referer => '/from_here_on'
  end
  
  def on_logout(options={})
    @user = users(:john)
    unless options[:without_user]
      delete 'destroy', {}, with_user(@user)
    else
      delete 'destroy'
    end
  end
  
  def with_referer(referer='/from_here_on')
    @referer = referer
    @request.env['HTTP_REFERER'] = '/from_here_on'
  end
end