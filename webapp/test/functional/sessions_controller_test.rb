require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "login required for logout" do
    assert_before_filter_applied :login_required, :destroy
  end
  
  test "sets stylesheets on new" do
    get 'new'
    assert_not_empty assigns(:stylesheets)
  end
  
  test "referer defaults to root on new" do
    get 'new'
    assert_equal '/', flash[:referer]
  end
  
  test "referer is passed in the flash on new" do
    with_referer
    get 'new'
    assert_equal @referer, flash[:referer]
  end
  
  test "sets user_id in session on valid login" do
    on_valid_login
    assert_equal @user.id, session[:user_id]
  end
  
  test "sets flash message on valid login" do
    on_valid_login
    assert_not_nil flash[:message]
  end
  
  test "redirects after valid login" do
    on_valid_login
    assert_redirected_to '/from_here_on'
  end
  
  test "keeps flash on invalid login" do
    on_invalid_login
    assert_equal '/from_here_on', flash[:referer]
  end
  
  test "sets wrong login or password flag on invalid login" do
    on_invalid_login
    assert flash[:wrong_login_or_password]
  end
  
  test "saves login in flash on invalid login" do
    on_invalid_login
    assert_equal @user.login, flash[:login]
  end
  
  test "redirects to login after invalid login" do
    on_invalid_login
    assert_redirected_to new_session_path
  end
  
  test "unsets user_id in session on logout" do
    on_logout
    assert_nil session[:user_id]
  end
  
  test "unsets user instance on logout" do
    on_logout
    assert_nil assigns(:current_user)
  end
  
  test "sets flash message on logout" do
    on_logout
    assert_not_nil flash[:message]
  end
  
  test "redirects with referer after logout" do
    with_referer
    on_logout
    assert_redirected_to @referer
  end
  
  test "redirects to root without referer after logout" do
    on_logout
    assert_redirected_to '/'
  end
  
private
  def on_valid_login
    @user = users(:john)
    post 'create', {:login => @user.login, :password => 'sekret'}, {}, {:referer => '/from_here_on'}
  end

  def on_invalid_login
    @user = users(:john)
    post 'create', {:login => @user.login, :password => 'wrong'}, {}, {:referer => '/from_here_on'}
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
