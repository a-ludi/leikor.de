require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  test "login required for new" do
    assert_before_filter_applied :login_required, @controller, :new
  end
  
  test "login required for create" do
    assert_before_filter_applied :login_required, @controller, :create
  end
  
  test "login required for edit" do
    assert_before_filter_applied :login_required, @controller, :edit
  end
  
  test "login required for update" do
    assert_before_filter_applied :login_required, @controller, :update
  end
  
  test "login required for ask_destroy" do
    assert_before_filter_applied :login_required, @controller, :ask_destroy
  end
  
  test "login required for destroy" do
    assert_before_filter_applied :login_required, @controller, :destroy
  end
  
  test "updates last updated after create" do
    assert_after_filter_applied
  end
end
