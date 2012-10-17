require 'test_helper'

class ArticleFeaturesControllerTest < ActionController::TestCase
  test "should list colors on index action" do
    on_index_action
    
    assert_equal Color.all, assigns(:colors)
  end
  
  test "should list materials on index action" do
    on_index_action
    
    assert_equal Material.all, assigns(:materials)
  end
  
  test "should set stylesheets and title on index action" do
    on_index_action
    
    assert_stylesheets_and_title
  end
  
  test "should use template index on index action" do
    on_index_action
    
    assert_template 'index'
  end

private

  def on_index_action
    get 'index'
  end
end
