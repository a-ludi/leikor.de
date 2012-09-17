require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  test_tested_files_checksum 'f39f5f0881926e7d1a88b65856c97ae8'
  
  def setup
    https! # all actions require SSL
    @user = users(:john)
  end
  
  test "all actions should require employee make groups and user" do
    [:employee_required, :make_groups, :fetch_user].each do |filter|
      assert_before_filter_applied filter
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
end
