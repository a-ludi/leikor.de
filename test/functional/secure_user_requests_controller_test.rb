require 'test_helper'

class SecureUserRequestsControllerTest < ActionController::TestCase
  tests_mailer Notifier
  
  test "before filters should be applied" do
    [:destroy_if_expired, :force_user_logout].each do |filter|
      [:edit, :update, :destroy].each do |action|
        assert_before_filter_applied filter, action
      end
    end
  end
  
  test "all actions should fetch secure user request" do
    assert_before_filter_applied :fetch_secure_user_request
  end
  
  test "new reset password action" do
    get :new, {:type => 'SecureUserRequest::ResetPassword'}
    
    assert_kind_of SecureUserRequest::ResetPassword, assigns(:secure_user_request)
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
    assert_template 'reset_password/new'
  end
  
  test "create reset password action without pending request" do
    @user = users(:moritz)
    post :create, {:login => @user.login, :type => 'SecureUserRequest::ResetPassword'}
    
    refute_empty flash[:message]
    assert_kind_of SecureUserRequest::ResetPassword, assigns(:secure_user_request)
    assert_present @user.reload.reset_password_request
    assert_mailed_to @user.primary_email_address
    assert_redirected_to :root
  end
  
  test "create reset password action with pending request" do
    @user = users(:john)
    post :create, {:login => @user.login, :type => 'SecureUserRequest::ResetPassword'}
    
    assert_equal @user.reset_password_request, assigns(:secure_user_request)
    assert @user.reset_password_request.updated_at < assigns(:secure_user_request).updated_at
  end
  
  test "create reset password action with pending confirm request" do
    @user = users(:max)
    post :create, {:login => @user.login, :type => 'SecureUserRequest::ResetPassword'}
    
    assert_nil @user.reload.reset_password_request
    refute_mail_sent
    refute_empty flash[:message]
  end
  
  test "create reset password action with unkown user" do
    post :create, {:login => 'unkown_login', :type => 'SecureUserRequest::ResetPassword'}
    
    refute_empty flash[:message]
    refute_mail_sent
    assert_redirected_to :root
  end
  
  test "edit reset password action" do
    @reset_password_request = secure_user_requests(:john_reset)
    @user = @reset_password_request.user
    get :edit, {:id => @reset_password_request.external_id}
    
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
    assert_template 'reset_password/edit'
  end
  
  test 'update reset password action with matching passwords' do
    post_update_reset_password
    
    assert_equal @user, assigns(:user)
    assert_equal @user.reload.password, @password
    assert_destroyed assigns(:secure_user_request)
    refute_empty flash[:message]
    assert @controller.send(:logged_in?, @user), 'user not logged in'
    assert_redirected_to :root
  end
  
  test 'update reset password action without matching passwords' do
    post_update_reset_password :with_errors
    
    assert_equal @user, assigns(:user)
    assert_errors_on assigns(:user), :on => :password #TODO why fails this?
    assert_template 'reset_password/edit'
  end
  
  test 'create confirm registration action creates request' do
    put_create_confirm_registration
    
    assert_equal @user, assigns(:user)
    assert_present assigns(:user).confirm_registration_request
    assert_present flash[:message]
    assert_redirected_to profile_path(@user.login)
  end

  test 'create confirm registration action updates request' do
    put_create_confirm_registration :request_pending
    
    assert @user.confirm_registration_request.updated_at < assigns(:user).confirm_registration_request.updated_at, 'request not touched'
  end

  test 'create confirm registration action bails with unkown user' do
    assert_raises ActiveRecord::RecordNotFound do
      put_create_confirm_registration :unkown_user
    end
  end

  test 'create confirm registration action requires employee' do
    put_create_confirm_registration :without_employee
    
    assert_redirected_to new_session_path
  end

  test 'create confirm registration action sends mail' do
    put_create_confirm_registration :send_mail
    
    assert_mailed_to @user.primary_email_address
    assert_present flash[:message]
  end
  
  test 'edit confirm registration action' do
    @confirm_registration_request = secure_user_requests(:max_confirm)
    @user = @confirm_registration_request.user
    get :edit, {:id => @confirm_registration_request.external_id}
    
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
    assert_template 'confirm_registration/edit'
  end
  
  test 'update confirm registration action' do
    post_update_confirm_registration
    
    assert_equal @user, assigns(:user)
    assert_destroyed assigns(:secure_user_request)
    assert_present flash[:message]
    assert @controller.send(:logged_in?, @user), 'user not logged in'
    assert_redirected_to my_profile_path
  end

  test 'update confirm registration action without matching passwords' do
    post_update_confirm_registration :with_errors
    
    assert_errors_on assigns(:user), :on => :new_password
    assert_template 'confirm_registration/edit'
  end

private
  
  def post_update_reset_password *options
    @reset_password_request = secure_user_requests(:john_reset)
    @user = @reset_password_request.user
    @password = 'new_password'
    confirm_password = options.include?(:with_errors) ? 'no_match' : @password
    post :update, {:id => @reset_password_request.external_id, :password => @password,
        :confirm_password => confirm_password}
  end
  
  def put_create_confirm_registration *options
    session = options.include?(:without_employee) ? {} : with_user
    @user = options.include?(:request_pending) ? users(:max) : users(:john)
    @user = User.new :login => 'unkown_user' if options.include? :unkown_user
    params = {:login => @user.login, :type => 'SecureUserRequest::ConfirmRegistration'}
    params[:sendmail] = options.include? :send_mail
    
    put :create, params, session
  end
  
  def post_update_confirm_registration *options
    @confirm_registration_request = secure_user_requests(:max_confirm)
    @user = @confirm_registration_request.user
    @password = 'new_password'
    confirm_password = options.include?(:with_errors) ? 'no_match' : @password
    post :update, {:id => @confirm_registration_request.external_id, :password => @password,
        :confirm_password => confirm_password}
  end  
end
