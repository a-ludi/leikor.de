require 'test_helper'

class SecureUserRequestsControllerTest < ActionController::TestCase
  tests_mailer Notifier
  test_tested_files_checksum '38bb5fde0fb776370b17913cbce4ecd4'
  
  def setup
    https! # every action requires SSL
  end
  
  test "ssl requirements" do
    @id = secure_user_requests(:max_confirm).to_param
    
    assert_https_required { get 'new', :type => 'SecureUserRequest::ResetPassword' }
    assert_https_required { post 'create', :type => 'SecureUserRequest::ConfirmRegistration' }
    assert_https_required { post 'create' }
    assert_https_required { post 'create', :format => 'js' }
    assert_https_required { get 'edit', :id => @id }
    assert_https_required { get 'edit', :id => @id, :format => 'js' }
    assert_https_required { get 'destroy', :id => @id }
    assert_https_required { get 'destroy', :id => @id, :format => 'js' }
    assert_https_required { put 'update', :id => @id }
    assert_https_required { put 'update', :id => @id, :format => 'js' }
    assert_https_required { delete 'destroy', :id => @id }
    assert_https_required { delete 'destroy', :id => @id, :format => 'js' }
  end
  
  test "on edit update destroy should force user logout" do
    [:edit, :update, :destroy].each do |action|
      assert_before_filter_applied :force_user_logout, action
    end
  end
  
  test "all actions should fetch secure user request" do
    assert_before_filter_applied :fetch_secure_user_request
  end
  
  test "all actions should destroy request if expired" do
    assert_before_filter_applied :destroy_request_if_expired
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
    @user = users(:maxi)
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

  test 'create confirm registration action responds to js' do
    put_create_confirm_registration :xhr
    
    assert_template :partial => 'layouts/_push_message'
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
  
  test 'fetch_secure_user_request with type given' do
    @secure_user_request = SecureUserRequest::ConfirmRegistration.new
    call_method :fetch_secure_user_request, [], :params => {:type => @secure_user_request.class.to_s}
    
    assert_equal @secure_user_request.hash, assigns(:secure_user_request).hash
    assert_new_record assigns(:secure_user_request)
  end

  test 'fetch_secure_user_request with id given' do
    @secure_user_request = secure_user_requests(:max_confirm)
    call_method :fetch_secure_user_request, [], :params => {:id => @secure_user_request.external_id}
    
    assert_equal @secure_user_request, assigns(:secure_user_request)
  end
  
  test 'missing_secure_user_request without referer' do
    call_method :missing_secure_user_request, [], :render => false, :params => {
        :type => 'SecureUserRequest::ConfirmRegistration'}
    
    assert_present flash[:message]
    refute @result
    assert_redirected_to :root
  end

  test 'missing_secure_user_request with referer' do
    with_referer
    call_method :missing_secure_user_request, [], :render => false, :params => {
        :type => 'SecureUserRequest::ConfirmRegistration'}
    
    assert_redirected_to @referer
  end
  
  test 'force_user_logout with user' do
    call_method :force_user_logout, [], :params => {:type =>
        'SecureUserRequest::ConfirmRegistration'}, :session => with_user
    
    assert_present flash[:message]
    refute @controller.send(:logged_in?)
  end

  test 'force_user_logout without user' do
    call_method :force_user_logout, [], :params => {:type =>
        'SecureUserRequest::ConfirmRegistration'}
    
    assert_blank flash[:message]
    refute @controller.send(:logged_in?)
  end
  
  test 'destroy_request_if_expired does not destroy new request' do
    call_method :destroy_request_if_expired, [], :params => {:type =>
        'SecureUserRequest::ConfirmRegistration'}
    
    assert_new_record assigns(:secure_user_request)
  end
  
  test 'destroy_request_if_expired destroys request' do
    @secure_user_request = secure_user_requests(:expired)
    call_method :destroy_request_if_expired, [], :params => {:id =>
        @secure_user_request.external_id}
    
    assert_destroyed assigns(:secure_user_request)
    assert_redirected_to :root
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
    @user = options.include?(:request_pending) ? users(:maxi) : users(:john)
    @user = User.new :login => 'unkown_user' if options.include? :unkown_user
    params = {:login => @user.login, :type => 'SecureUserRequest::ConfirmRegistration'}
    params[:sendmail] = options.include? :send_mail
    
    unless options.include? :xhr
      put :create, params, session
    else
      xhr :put, :create, params, session
    end
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
