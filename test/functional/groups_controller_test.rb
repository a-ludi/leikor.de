require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  test_tested_files_checksum '452e1667dbe0443a4aa6c76094439a92'

  def setup
    https! # every action require SSL
    @user = users(:john)
  end
  
  test "ssl requirements" do
    @profile_id = users(:john).login
    @id = 'Holz'
    refute_https_allowed { post 'create', :profile_id => @profile_id }
    refute_https_allowed { put 'update', :profile_id => @profile_id, :id => @id }
    refute_https_allowed { delete 'destroy', :profile_id => @profile_id, :id => @id }
    refute_https_allowed { get 'suggest' }
  end
    
  test "all actions should require employee" do
    assert_before_filter_applied :employee_required
  end
  
  test "create update destroy should fetch user" do
    [:create, :update, :destroy].each do |action|
      assert_before_filter_applied :fetch_user, action
    end
  end
  
  test "create update destroy should make groups" do
    [:create, :update, :destroy].each do |action|
      assert_before_filter_applied :make_groups, action
    end
  end
  
  test "create action" do
    @groups = 'New Group'
    post :create, {:profile_id => @user.login, :id => @groups}, with_employee
    
    assert_success
    @user.reload
    assert_includes @user.group_list, @groups
  end

  test "update action" do
    @groups = @user.group_list.first
    @new_groups = 'New Group'
    put :update, {:profile_id => @user.login, :id => @groups, :new_groups => @new_groups},
        with_employee
    
    assert_success
    @user.reload
    refute_includes @user.group_list, @groups
    assert_includes @user.group_list, @new_groups
  end

  test "destroy action" do
    @groups = @user.group_list.first
    delete :destroy, {:profile_id => @user.login, :id => @groups}, with_employee
    
    assert_success
    @user.reload
    refute_includes @user.group_list, @groups
  end
  
  test "suggest action" do
    @token = 'Ho'
    get :suggest, {:token => @token}, with_employee
    
    assert_equal [User.group_counts.find_by_name('Holz')], assigns(:suggestions)
    assert_template 'suggest'
    assert_layout false
  end
  
  test "suggest action returns at least 10 suggestions" do
    @token = 'Su'
    generate_15_groups_with_token
    get :suggest, {:token => @token}, with_employee
    
    assert assigns(:suggestions).count <= 10, 'too many suggestions found'
  end
  
  test "suggest action returns matching suggestions" do
    @token = 'Su'
    generate_15_groups_with_token
    get :suggest, {:token => @token}, with_employee
    
    assigns(:suggestions).each do |suggestion|
      assert suggestion.start_with?(*@groups)
    end
  end
  
  test "make_groups" do
    @groups = %w(Lots Of Different Groups)
    post :create, {:profile_id => @user.login, :id => @groups.join(', ')}, with_employee
    
    assert_equal @groups, assigns(:groups)
  end

  test "fetch_user succeeds" do
    post :create, {:profile_id => @user.login, :id => ''}, with_employee
    
    assert_equal @user, assigns(:user)
  end

  test "fetch_user fails" do
    begin
      post :create, {:profile_id => 'no_id', :id => ''}, with_employee
    rescue ActiveRecord::RecordNotFound then pass
    else fail
    end
  end

private
  
  def assert_success
    assert_present flash[:message]
    if @request.xhr?
      assert_equal @groups, @response.body
    else
      assert_redirected_to profile_path(@user)
    end
  end
  
  def generate_15_groups_with_token
    suffixes = %w(si sanne fle ppe che per ende shi btil ffix izid lfat urfen perb bjekt)
    @groups = suffixes.map{|suffix| @token + suffix}
    assert_equal 15, @groups.count
    
    users(:john).group_list = @groups.join ','
  end
end
