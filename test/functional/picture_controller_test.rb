# -*- encoding : utf-8 -*-
require 'test_helper'

class PictureControllerTest < ActionController::TestCase
  test_tested_files_checksum 'ab3ef36a4880bcf4a40fa3e224692088'
  
  test "login required except show pictures" do
    [:show, :pictures].each do |action|
      assert_before_filter_not_applied :employee_required, action
    end
  end
  
  test "save updated at only update destroy" do
    [:update, :destroy].each do |action|
      assert_after_filter_applied :save_updated_at, action
    end
  end
  
  test "pictures action" do
    @article = articles(:one)
    https!
    put 'update', {:article_id => @article.to_param, :article => {:picture => image(:jpg)}}, with_user
    
    [:original, :medium, :thumb].each do |style|
      get 'pictures', :article_id => @article.to_param, :style => style
      
      assert_response :success
    end
  end
  
  test "show format html" do
    @article = articles(:one)
    get 'show', :format => 'html', :article_id => @article.to_param
    
    assert_equal @article, assigns(:article)
    assert_present assigns(:title)
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
    https!
    get 'edit', {:article_id => @article.to_param, :popup => '1'}, with_user
    
    assert_equal @article, assigns(:article)
    assert_stylesheets_and_title
    assert assigns(:popup)
    assert_template 'edit'
    assert_layout 'popup'
  end
  
  test "edit action without popup" do
    @article = articles(:one)
    https!
    get 'edit', {:article_id => @article.to_param}, with_user
    
    assert ! assigns(:popup)
    assert_template 'edit'
  end
  
  test "update action with jpg" do
    @article = articles(:one)
    https!
    put 'update', {:article_id => @article.to_param, :article => {:picture => image(:jpg)}},
        with_user
    
    assert_equal @article, assigns(:article)
    assert_no_errors_on assigns(:article), :on => :picture
    assert_equal 'image/jpg', assigns(:article).picture.content_type
    assert_present flash[:message]
  end
  
  test "update action with png" do
    @article = articles(:one)
    https!
    put 'update', {:article_id => @article.to_param, :article => {:picture => image(:png)}},
        with_user
    
    assert_no_errors_on assigns(:article), :on => :picture
    assert_equal 'image/png', assigns(:article).picture.content_type
  end
  
  test "update action with not image" do
    @article = articles(:one)
    https!
    put 'update', {:article_id => @article.to_param, :article => {:picture => image(:not_image)}},
        with_user
    
    assert_errors_on assigns(:article), :on => :picture
  end
  
  test "destroy with popup" do
    @article = articles(:one)
    https!
    delete 'destroy', {:article_id => @article.to_param, :popup => true}, with_user
    
    assert_equal @article, assigns(:article)
    assert ! assigns(:article).picture.file?
    assert_present flash[:message]
    assert_template 'success'
    assert_layout 'popup'
  end
  
  test "destroy without popup" do
    @article = articles(:one)
    https!
    delete 'destroy', {:article_id => @article.to_param}, with_user
    
    assert_redirected_to subcategory_url(@article.subcategory.url_hash)
  end
  
  test "try_save_and_render_response with success" do
    successful_request # gives success message
    
    assert_stylesheets_and_title
    assert_present flash[:message]
    assert ! assigns(:article).picture.dirty?
  end
  
  test "try_save_and_render_response with failure" do
    failed_request
    
    assert_errors_on assigns(:article), :on => :picture
  end
  
  test "render_response with success and popup" do
    successful_request :popup => true
    
    assert_present assigns(:title)
    assert_template 'success'
    assert_layout 'popup'
  end

  test "render_response with success and popup passes title" do
    custom_title = 'Mein Titel'
    @controller.instance_eval { @title = custom_title }
    successful_request :popup => true
    
    assert_equal custom_title, assigns(:title)
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
  
  IMAGE_MIME_TYPE = {:jpg => 'image/jpg', :png => 'image/png', :not_image => 'text/plain',
      :small => 'image/png'}
  
  def image(name)
    fixture_file_upload "pictures/#{name.to_s}", self.class::IMAGE_MIME_TYPE[name], :binary
  end
  
  def successful_request(options={})
    @article = articles(:one)
    https!
    delete 'destroy', {:article_id => @article.to_param, :popup => options[:popup]}, with_user
  end
  
  def failed_request(options={})
    @article = articles(:one)
    https!
    put 'update', {:article_id => @article.to_param, :article => {:picture => image(:not_image)},
        :popup => options[:popup]}, with_user
  end
end
