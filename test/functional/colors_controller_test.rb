require 'test_helper'

class ColorsControllerTest < ActionController::TestCase
  test "should set new color on new action" do
    on_new_action
    
    assert_present assigns(:color)
    assert assigns(:color).new_record?, 'not a new record'
  end

  test "should set a default value of #dd2200 for hex on new action" do
    on_new_action
    
    assert_equal '#dd2200', assigns(:color).hex
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
