require 'test_helper'

class MaterialsControllerTest < ActionController::TestCase
  test "should set new material on new action" do
    on_new_action
    
    assert_present assigns(:material)
    assert assigns(:material).new_record?, 'not a new record'
  end

  test "should set stylesheets and title on new action" do
    on_new_action
    
    assert_stylesheets_and_title
  end

  test "should use template edit on new action" do
    on_new_action
    
    assert_template 'edit'
  end

private
  
  def on_new_action
    get 'new'
  end
end
