require 'test_helper'

class HeaderImagesControllerTest < ActionController::TestCase
  def setup
    https!
  end
  
  test "update action without params[:article_number]" do
    put :update, {:id => 'links'}, with_employee
    
    assert_nil assigns(:article)
    assert_equal 'left_header_image_path', assigns(:hash_key)
    assert AppData['left_header_image_path'].blank?, "AppData['left_header_image_path'] was not blank"
    assert_present flash[:message]
    assert_template :partial => 'layouts/_push_message'
  end
  
  test "update action with params[:article_number]" do
    @article = articles(:one)
    put :update, {:id => 'rechts', :article_number => @article.article_number}, with_employee
    
    assert_equal @article, assigns(:article)
    assert_equal 'right_header_image_path', assigns(:hash_key)
    assert_present AppData['right_header_image_path']
  end
end
