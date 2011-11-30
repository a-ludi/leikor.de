require 'test_helper'

class PictureControllerTest < ActionController::TestCase
  #fixture_file_upload
  test "login required except show" do
    [:edit, :update, :destroy].each do |action|
      assert_before_filter_applied :login_required, action
    end
  end
  
  test "save updated at only update destroy" do
    [:update, :destroy].each do |action|
      assert_after_filter_applied :save_updated_at, action
    end
  end
  
  test "show format html" do
    @article = articles(:one)
    get 'show', :format => 'html', :article_id => @article.to_param
    
    assert_equal @article, assigns(:article)
    assert_template '_viewer'
    assert_layout 'popup'
  end
  
  test "show format js" do
    @article = articles(:one)
    get 'show', :format => 'js', :article_id => @article.to_param, :no_animations => :test_value
    
    assert_equal :test_value, flash[:no_animations]
    assert_template 'show'
  end
  
  test "destroy with popup" do
    @article = articles(:one)
    delete 'destroy', {:article_id => @article.to_param}, with_user, {:popup => true}
    
    assert_equal @article, assigns(:article)
    assert ! assigns(:article).picture.file?
    assert_not_empty flash[:message]
    assert_template 'success'
    assert_layout 'popup'
  end
  
  test "destroy without popup" do
    @article = articles(:one)
    delete 'destroy', {:article_id => @article.to_param}, with_user
    
    assert_redirected_to subcategory_url(@article.subcategory.url_hash)
  end
end
