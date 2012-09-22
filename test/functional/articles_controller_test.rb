# -*- encoding : utf-8 -*-
require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  test_tested_files_checksum '8964002b761e81fc942dea3e4867161b'
  
  test "ssl requirements" do
    @article = articles(:one)
    @subcategory = @article.subcategory
    @category = @subcategory.category
    
    refute_https_allowed { get 'index', @subcategory.url_hash }
    refute_https_allowed { get 'edit_order', @subcategory.url_hash }
    refute_https_allowed { post 'reorder', @subcategory.url_hash }
    refute_https_allowed { get 'ask_destroy', @article.url_hash }
    refute_https_allowed { get 'index' }
    refute_https_allowed { get 'index', :format => 'js' }
    refute_https_allowed { post 'create' }
    refute_https_allowed { post 'create', :format => 'js' }
    refute_https_allowed { get 'new' }
    refute_https_allowed { get 'new', :format => 'js' }
    refute_https_allowed { get 'edit', :id => @article.to_param }
    refute_https_allowed { get 'edit', :id => @article.to_param, :format => 'js' }
    refute_https_allowed { put 'update', :id => @article.to_param }
    refute_https_allowed { put 'update', :id => @article.to_param, :format => 'js' }
    refute_https_allowed { delete 'destroy', :id => @article.to_param }
    refute_https_allowed { delete 'destroy', :id => @article.to_param, :format => 'js' }
  end
  
  test "new edit_order create edit update ask_destroy destroy reorder actions should require
      employee" do
    [:new, :create, :edit_order, :edit, :update, :ask_destroy, :destroy, :reorder].each do |action|
      assert_before_filter_applied :employee_required, action
    end
  end
  
  test "index action should not require employee" do
    assert_before_filter_not_applied :employee_required, :index
  end
  
  test "index edit_order action should fetch categories" do
    [:index, :edit_order].each do |action|
      assert_before_filter_applied :fetch_categories, action
    end
  end
  
  test "create update destroy reorder actions should save updated_at" do
    [:create, :update, :destroy, :reorder].each do |action|
      assert_after_filter_applied :save_updated_at, action
    end
  end
  
  test "index action" do
    get_index
    
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
    assert_present assigns(:scroll_target)
  end
  
  test "new action sets proper article" do
    get_new
    
    assert_kind_of Article, assigns(:article)
    assert_no_errors_on assigns(:article)
  end
  
  test "new action with cancel" do
    get_new :cancel => true
    
    assert assigns(:cancel)
    assert_present assigns(:html_id)
  end
  
  test "edit_order action" do
    @subcategory = categories(:sub1)
    @category = @subcategory.category
    https!
    get 'edit_order', {:category => @category.to_param, :subcategory => @subcategory.to_param}, with_user
    
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
  end
  
  test "successful create action" do
    post_create
    
    assert_equal @subcategory, @controller.params[:article][:subcategory]
    assert_kind_of Article, assigns(:article)
    assert_equal 'article', assigns(:partial)
    assert_equal @html_id, flash[:html_id]
    assert_template 'edit'
  end
  
  test "failed create action" do
    post_create :with => :errors
    
    assert_errors_on assigns(:article)
    assert_equal 'form', assigns(:partial)
    assert_template 'edit'
  end
  
  test "edit action" do
    get_edit
    
    assert_equal @article, assigns(:article)
    assert_equal 'form', assigns(:partial)
  end
  
  test "cancel edit action" do
    get_edit :cancel => true
    
    assert_equal @article, assigns(:article)
    assert_equal 'article', assigns(:partial)
  end

  test "update action" do
    put_update
    
    assert_equal @article, assigns(:article)
    assert_equal @html_id, flash[:html_id]
    assert_kind_of Float, @controller.params[:article][:price]
    assert_equal @new_name, assigns(:article).name
    assert_equal 'article', assigns(:partial)
    assert_equal @article.id, flash[:saved_article_id]
    assert_template 'edit'
  end
  
  test "failed update action" do
    put_update :with => :errors
    
    assert_equal 'form', assigns(:partial)
  end
  
  test "ask_destroy action" do
    @article = articles(:one)
    https!
    get 'ask_destroy', @article.url_hash, with_user
    
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
    assert_equal @article, assigns(:article)
  end
  
  test "destroy action" do
    @article = articles(:one)
    https!
    delete 'destroy', {:id => @article.to_param}, with_user
    
    assert_equal @article, assigns(:article)
    assert assigns(:article).destroyed?
    refute Article.exists?(@article.id)
    refute_empty flash[:message]
    assert_redirected_to subcategory_url(@article.subcategory.url_hash)
  end
  
  test "reorder action" do
    @articles_list = Article.find(:all, :order => "RANDOM()").collect {|a| a.id}
    @subcategory = categories(:sub1)
    @category = categories(:sub1).category
    
    https!
    post 'reorder', {:subcategory => @subcategory.to_param,
        :category => @category.to_param, :articles_list => @articles_list}, with_user
    
    @new_articles_list = Article.find(:all, :order => "ord ASC").collect {|a| a.id}
    assert_equal @articles_list, @new_articles_list
  end
  
  test "generated_article_number" do
    article_numbers = []
    50.times do
      article_numbers << @controller.send(:generated_article_number)
      assert_exact_match Article::ARTICLE_NUMBER_FORMAT, article_numbers.last
    end
    assert_items_unique article_numbers
  end
  
  test "get_price_from_param" do
    ['11.11', '11,11'].each do |price|
      assert_equal 11.11, @controller.send(:get_price_from_param, price), "price is <#{price.inspect}>"
    end
  end
  
private
  def get_index
    @subcategory = categories(:sub1)
    @category = @subcategory.category
    
    get 'index', {:category => @category.to_param, :subcategory => @subcategory.to_param}
  end
  
  def get_new(options={})
    @subcategory = categories(:sub1)
    @category = @subcategory.category
    if options[:cancel]
      @html_id = articles(:one).html_id
      cancel = {:cancel => true, :html_id => @html_id}
    else
      cancel = {}
    end
    
    https!
    get 'new', {:category => @category.to_param, :subcategory => @subcategory.to_param}.merge(cancel), with_user
  end
  
  def post_create(options={})
    @subcategory = categories(:sub1)
    @article = {
      :name => 'Testy',
      :description => 'Testy is used for testing purposes.',
      :price => '11,11',
      :article_number => '12345.6',
      :subcategory_id => @subcategory.id}
    @article[:name] = '' if options[:with] == :errors
    @html_id = articles(:one).html_id
    
    https!
    post 'create', {:article => @article, :html_id => @html_id}, with_user
  end
  
  def get_edit(options={})
    @article = articles(:one)
    params = {:id => @article.to_param}.merge(options)
    
    https!
    get 'edit', params, with_user
  end
  
  def put_update(options={})
    @article = articles(:one)
    @new_name = 'New Name'
    @html_id = @article.html_id
    params = {:id => @article.to_param, :article => {:name => @new_name, :price => '11,11'}, :html_id => @html_id}
    params[:article][:name] = '' if options[:with] == :errors
    
    https!
    put 'update', params, with_user
  end
end
