require 'test_helper'

class PictureControllerTest < ActionController::TestCase
  test "login required except show" do
    [:show, :pictures].each do |action|
      assert_before_filter_not_applied :login_required, action
    end
  end
  
  test "save updated at only update destroy" do
    [:update, :destroy].each do |action|
      assert_after_filter_applied :save_updated_at, action
    end
  end
  
  test "pictures action" do
    @article = articles(:one)
    picture = fixture_file_upload 'pictures/jpg', 'image/small', :binary
    put 'update', {:article_id => @article.to_param, :article => {:picture => picture}}, with_user
    
    [:original, :medium, :thumb].each do |style|
      get 'pictures', :article_id => @article.to_param, :style => style
      
      assert_response :success
    end
  end
  
  test "show format html" do
    @article = articles(:one)
    get 'show', :format => 'html', :article_id => @article.to_param
    
    assert_equal @article, assigns(:article)
    assert_non_empty_kind_of String, assigns(:title)
    assert_template '_viewer'
    assert_layout 'popup'
  end
  
  test "show format js" do
    @article = articles(:one)
    get 'show', :format => 'js', :article_id => @article.to_param, :no_animations => :test_value
    
    assert_equal :test_value, flash[:no_animations]
    assert_template 'show'
  end
  
  test "edit action with popup" do
    @article = articles(:one)
    get 'edit', {:article_id => @article.to_param, :popup => '1'}, with_user
    
    assert_equal @article, assigns(:article)
    assert_respond_to assigns(:stylesheets), :each
    assert_non_empty_kind_of String, assigns(:title)
    assert assigns(:popup)
    assert_template 'edit'
    assert_layout 'popup'
  end
  
  test "edit action without popup" do
    @article = articles(:one)
    get 'edit', {:article_id => @article.to_param}, with_user
    
    assert ! assigns(:popup)
    assert_template 'edit'
  end
  
  test "update action with jpg" do
    @article = articles(:one)
    picture = fixture_file_upload 'pictures/jpg', 'image/jpg', :binary
    put 'update', {:article_id => @article.to_param, :article => {:picture => picture}}, with_user
    
    assert_equal @article, assigns(:article)
    assert assigns(:article).picture.valid?
    assert_equal 'image/jpg', assigns(:article).picture.content_type
    assert_not_empty flash[:message]
  end
  
  test "update action with png" do
    @article = articles(:one)
    picture = fixture_file_upload 'pictures/png', 'image/png', :binary
    put 'update', {:article_id => @article.to_param, :article => {:picture => picture}}, with_user
    
    assert assigns(:article).picture.valid?
    assert_equal 'image/png', assigns(:article).picture.content_type
  end
  
  test "update action with not image" do
    @article = articles(:one)
    picture = fixture_file_upload 'pictures/not_image', 'text/plain', :binary
    put 'update', {:article_id => @article.to_param, :article => {:picture => picture}}, with_user
    
    assert ! assigns(:article).picture.valid?
    assert_errors_on assigns(:article), :on => :picture
  end
  
  test "destroy with popup" do
    @article = articles(:one)
    delete 'destroy', {:article_id => @article.to_param, :popup => true}, with_user
    
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
  
  test "try_save_and_render_response with success" do
    successful_request # gives success message
    
    assert_respond_to assigns(:stylesheets), :each
    assert_not_empty flash[:message]
    assert ! assigns(:article).picture.dirty?
  end
  
  test "try_save_and_render_response with failure" do
    failed_request
    
    assert_errors_on assigns(:article), :on => :picture
  end
  
  test "render_response with success and popup" do
    successful_request :popup => true
    
    assert_non_empty_kind_of String, assigns(:title)
    assert_template 'success'
    assert_layout 'popup'
  end

  test "render_response with success and no popup" do
    successful_request :popup => false
    
    assert_redirected_to subcategory_url(@article.subcategory.url_hash)
  end

  test "render_response with failure and popup" do
    failed_request :popup => true
    
    assert_template 'edit'
    assert_layout 'popup'
  end
  
  test "render_response with failure and no popup" do
    failed_request :popup => false
    
    assert_template 'edit'
    assert_layout 'application'
  end
  
private
  
  def successful_request(options={})
    @article = articles(:one)
    delete 'destroy', {:article_id => @article.to_param, :popup => options[:popup]}, with_user
  end
  
  def failed_request(options={})
    @article = articles(:one)
    picture = fixture_file_upload 'pictures/not_image', 'text/plain', :binary
    put 'update', {:article_id => @article.to_param, :article => {:picture => picture}, :popup => options[:popup]}, with_user
  end
  
  def intermediate_request()
    get 'show', {:article_id => @article.to_param}
  end
end
