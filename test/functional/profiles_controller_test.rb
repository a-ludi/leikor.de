require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  test_tested_files_checksum '4d61e72e301585a302017620f86750d6'
  
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
  
  test "show_mine edit_mine update_mine edit_password update_password actions should set
      my_profile" do
    [:show_mine, :edit_mine, :update_mine, :edit_password, :update_password].each do |action|
      assert_before_filter_applied :set_my_profile, action
    end
  end
  
  test "show show_mine edit edit_mine update update_mine edit_password update_password destroy
      actions should set @profile" do
    [:edit_password, :update_password, :show, :show_mine, :edit, :edit_mine, :update, :update_mine,
        :destroy].each do |action|
      assert_before_filter_applied :set_profile, action
    end
  end
  
  test "index action" do
    get :index, {}, with_employee
    
    assert_respond_to assigns(:customers), :each
    assigns(:customers).each {|user| assert_kind_of Customer, user}
    assert_respond_to assigns(:employees), :each
    assigns(:employees).each {|user| assert_kind_of Employee, user}
    assert_equal users(:meyer, :moritz), assigns(:customers)
    assert_equal users(:john, :maxi), assigns(:employees)
    assert_stylesheets_and_title
  end
  
  test "show action" do
    @profile = users(:moritz)
    get :show, {:id => @profile.login}, with_employee
    
    assert_equal @profile, assigns(:profile)
    assert_stylesheets_and_title
    assert_template :show
  end
  
  test "show_mine action" do
    get :show_mine, {}, with_customer
    
    assert_equal @user, assigns(:profile)
    assert assigns(:my_profile), 'not my profile'
    assert_stylesheets_and_title
    assert_template :show
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

  test "new action with should use flash[:profile] first" do
    @profile = Customer.new :login => 'alice'
    get :new, {:type => @profile.class.to_s}, with_employee, :profile => @profile
    
    assert_equal @profile, assigns(:profile)
  end
  
  test "create action successful" do
    post_create
    
    assert_kind_of @profile.class, assigns(:profile)
    @profile.attributes.each do |key, value|
      assert_equal value, assigns(:profile)[key] unless value.blank?
    end
    assert_present assigns(:profile).password
    assert_present assigns(:profile).confirm_registration_request
    assert_present flash[:message]
    assert_redirected_to profile_path(assigns(:profile).login)
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

  test "edit_mine action" do
    get :edit_mine, {}, with_customer
    
    assert assigns(:my_profile), 'not my profile'
    assert_equal @user, assigns(:profile)
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
    assert_errors_on assigns(:profile), :on => :name
    assert_redirected_to edit_profile_path(@profile.login)
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
    assert_errors_on assigns(:profile), :on => :name
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
    refute_equal @user.reload.password, @new_password
    assert_errors_on assigns(:profile), :on => :password
    assert_redirected_to edit_password_path
  end

  test "update_password action with incorrect confirmation" do
    put_update_password :with_incorrect_confirmation
    
    assert_equal @user, assigns(:profile)
    refute_equal @user.reload.password, @new_password
    assert_errors_on assigns(:profile), :on => :new_password
    assert_redirected_to edit_password_path
  end

  test "update_password action with short password" do
    put_update_password :with_short_password
    
    assert_equal @user, assigns(:profile)
    refute_equal @user.reload.password, @new_password
    assert_errors_on assigns(:profile), :on => :password
    assert_redirected_to edit_password_path
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
  
  test "show_path with new profile" do
    @profile = User.new
    @controller.instance_variable_set(:@profile, @profile)
    
    assert_equal profiles_path, @controller.send(:show_path)
  end
  
  test "show_path with my_profile" do
    @profile = users(:john)
    @controller.instance_variable_set(:@profile, @profile)
    @controller.instance_variable_set(:@my_profile, true)
    
    assert_equal my_profile_path, @controller.send(:show_path)
  end
  
  test "show_path with profile" do
    @profile = users(:john)
    @controller.instance_variable_set(:@profile, @profile)
    
    assert_equal profile_path(@profile.login), @controller.send(:show_path)
  end
  
  test "edit_path with my_profile" do
    @controller.instance_variable_set(:@my_profile, true)
    
    assert_equal edit_my_profile_path, @controller.send(:edit_path)
  end
  
  test "edit_path with profile" do
    @profile = users(:john)
    @controller.instance_variable_set(:@profile, @profile)
    
    assert_equal edit_profile_path(@profile.login), @controller.send(:edit_path)
  end
  
  test "set_my_profile" do
    @controller.send :set_my_profile
    
    assert @controller.instance_variable_get(:@my_profile), '@my_profile not set'
  end
  
  test "set_profile with flash[:profile]" do
    @profile = users(:john)
    call_set_profile_with_profile_in_flash
    
    assert_equal @profile, assigns(:profile)
  end
  
private

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
  
  def delete_destroy(*options)
    @login = options.include?(:with_unkown_user) ? 'unkown' : users(:moritz).login
    
    delete :destroy, {:id => @login}, with_employee
  end
  
  def call_set_profile_with_profile_in_flash
    get :show, {:id => 'unkown_user'}, with_employee, :profile => @profile
  end
end
