require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  test "all actions should require user" do
    assert_before_filter_applied :user_required
  end
  
  test "index new create edit update destroy actions should require
      employee" do
    [:index, :new, :create, :edit, :update, :destroy].each do |action|
      assert_before_filter_applied :employee_required, action
    end
  end
  
  test "show_mine edit_mine update_mine edit_password update_password actions should not require
      employee" do
    [:show_mine, :edit_mine, :update_mine, :edit_password, :update_password].each do |action|
      assert_before_filter_not_applied :employee_required, action
    end
  end
  
  test "show_mine action" do
    get :show_mine, {}, with_customer
    
    assert_equal @user, assigns(:profile)
    assert assigns(:my_profile), 'not my profile'
    assert_stylesheets_and_title
    assert_template :show
  end
  
  test "edit_mine action" do
    get :edit_mine, {}, with_customer
    
    assert_equal @user, assigns(:profile)
    assert assigns(:my_profile), 'not my profile'
    assert_stylesheets_and_title
    assert_template :edit
  end
  
  test "update_mine action successful" do
    put_update_mine
    
    assert_equal @user.login, assigns(:profile).login
    assert assigns(:my_profile), 'not my profile'
    assert_equal @new_name, assigns(:profile).name
    assert_present flash[:message]
    assert_redirected_to my_profile_path
  end
  
  test "update_mine action failed" do
    put_update_mine :with_errors
    
    assert_equal @user.login, assigns(:profile).login
    assert assigns(:my_profile), 'not my profile'
    assert_errors_on assigns(:profile)
    assert_redirected_to edit_my_profile_path
  end
  
  test "edit_password action" do
    get :edit_password, {}, with_customer
    
    assert_equal @user, assigns(:profile)
    assert_stylesheets_and_title
    assert_template :edit_password
  end
  
  test "update_password action successful" do
    put_update_password
    
    assert_equal @user, assigns(:profile)
    assert_equal assigns(:profile).password, @new_password
    assert_present flash[:message]
    assert_redirected_to my_profile_path
  end

  test "update_password action with wrong password" do
    put_update_password :with_wrong_password
    
    assert_equal @user, assigns(:profile)
    assert_errors_on assigns(:profile), :on => :password
    assert_redirected_to edit_password_path
  end

  test "update_password action with incorrect confirmation" do
    put_update_password :with_incorrect_confirmation
    
    assert_equal @user, assigns(:profile)
    assert_errors_on assigns(:profile), :on => :new_password
    assert_redirected_to edit_password_path
  end

  test "update_password action with short password" do
    put_update_password :with_short_password
    
    assert_equal @user, assigns(:profile)
    assert_errors_on assigns(:profile), :on => :password
    assert_redirected_to edit_password_path
  end
  
  test "index action" do
    get :index, {}, with_employee
    
    assert_respond_to assigns(:employees), :each
    assigns(:employees).each {|user| assert_kind_of Employee, user}
    assert_respond_to assigns(:customers), :each
    assigns(:customers).each {|user| assert_kind_of Customer, user}
    assert_stylesheets_and_title
  end
  
  test "new action with customer" do
    @type = Customer
    get :new, {:type => @type.to_s}, with_employee
    
    assert_kind_of @type, assigns(:profile)
    assert_stylesheets_and_title
    assert_template :edit
  end
  
  test "new action with employee" do
    @type = Employee
    get :new, {:type => @type.to_s}, with_employee
    
    assert_kind_of @type, assigns(:profile)
    assert_stylesheets_and_title
    assert_template :edit
  end

  test "new action with unkown type should not create user" do
    assert_raises ActionController::RoutingError do
      get :new, {:type => 'unkown'}, with_employee
    end
  end
  
  test "create action successful" do
    post_create
    
    assert_kind_of @profile.class, assigns(:profile)
    assert_present assigns(:profile).password
    assert_present assigns(:profile).confirm_registration_request
    assert_redirected_to profile_path(@profile.login)
    assert_present flash[:message]
  end
  
  test "create action failed" do
    post_create :with_errors
    
    assert_kind_of @profile.class, assigns(:profile)
    assert_redirected_to @controller.send(:new_profile_path, @profile.class)
    assert_equal assigns(:profile), flash[:profile]
  end

  test "edit action" do
    @profile = users(:moritz)
    get :edit, {:id => @profile.login}, with_employee
    
    assert_equal @profile, assigns(:profile)
    assert_stylesheets_and_title
    assert_template :edit
  end
  
  test "update action successful" do
    put_update
    
    assert_equal @profile.login, assigns(:profile).login
    assert_equal @new_name, assigns(:profile).name
    assert_present flash[:message]
    assert_redirected_to profile_path(@profile.login)
  end
  
  test "update action failed" do
    put_update :with_errors
    
    assert_equal @profile.login, assigns(:profile).login
    assert_errors_on assigns(:profile)
    assert_redirected_to edit_profile_path(@profile.login)
  end
  
  test "destroy action" do
    delete_destroy
    
    assert_equal @login, assigns(:profile).login
    assert_destroyed assigns(:profile)
    assert_present flash[:message]
    assert_redirected_to profiles_path
  end
  
  test "destroy action with_unkown_user" do
    assert_raises ActiveRecord::RecordNotFound do
      delete_destroy :with_unkown_user
    end
  end
  
  test "new_profile_path" do
    assert_equal new_customer_profile_path, @controller.send(:new_profile_path, Customer)
    assert_equal new_employee_profile_path, @controller.send(:new_profile_path, Employee)
  end
  
private

  def put_update_mine(*options)
    @user = Customer.first
    @new_name = options.include?(:with_errors) ? '' : 'New Name'
    profile = @user.attributes.update 'name' => @new_name
    
    post :update_mine, {:profile => profile}, with_user(@user)
  end
  
  def put_update_password(*options)
    @user = users(:moritz)
    password = options.include?(:with_wrong_password) ? 'wrong_password' : 'geheim'
    @new_password = options.include?(:with_short_password) ? 'short' : 'sekret_passwort'
    new_password_confirm = options.include?(:with_incorrect_confirmation) ? 'wrong' : @new_password
    
    params = {:password => password, :new_password => @new_password,
        :confirm_new_password => new_password_confirm}
    
    post :update_password, params, with_user(@user)
  end
  
  def post_create(*options)
    @profile = Customer.new({
        :login => (options.include?(:with_errors) ? '' : 'neuer-kunde'),
        :name => 'Neuer Kunde',
        :notes => 'Notizen zu neuen Kunden sind toll.',
        :primary_email_address => 'neuer@kunde.de'})
    
    post :create, {:profile => @profile.attributes}, with_employee
  end

  def put_update(*options)
    @profile = users(:moritz)
    @new_name = options.include?(:with_errors) ? '' : 'New Name'
    profile = @profile.attributes.update 'name' => @new_name
    
    put :update, {:id => @profile.login, :profile => profile}, with_employee
  end
  
  def delete_destroy(*options)
    @login = options.include?(:with_unkown_user) ? 'unkown' : users(:moritz).login
    
    delete :destroy, {:id => @login}, with_employee
  end
end
