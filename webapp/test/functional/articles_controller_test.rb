require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  test "new create edit update ask_destroy destroy actions should require login" do
    [:new, :create, :edit, :update, :ask_destroy, :destroy].each do |action|
      assert_before_filter_applied :login_required, @controller, action
    end
  end
  
  test "index action should not require login" do
    assert_before_filter_not_applied :login_required, @controller, :index
  end
  
  test "index action should fetch categories" do
    assert_before_filter_applied :fetch_categories, @controller, :index
  end
  
  test "create update destroy actions should save updated_at" do
    [:create, :update, :destroy].each do |action|
      assert_after_filter_applied :save_updated_at, @controller, action
    end
  end
  
  test "index action" do
    get_index
    assert_respond_to assigns(:stylesheets), :each
    assert_kind_of String, assigns(:title)
  end
  
  test "new action sets proper article" do
    get_new
    assert_kind_of Article, assigns(:article)
    assert_non_empty_kind_of String, assigns(:article).name
    assert_non_empty_kind_of String, assigns(:article).description
    assert_equal 0.0, assigns(:article).price
    assert_non_empty_kind_of String, assigns(:article).article_number
    assert_kind_of Fixnum, assigns(:article).subcategory_id
  end
  
  test "new action with cancel" do
    get_new :cancel => true
    assert assigns(:cancel)
    assert_non_empty_kind_of String, assigns(:html_id)
  end
  
  test "new action sets html_id on cancel" do
    get_new :cancel => true
  end
  
  test "successful create action" do
    post_create
    assert_kind_of Float, @controller.params[:article][:price]
    assert_kind_of Subcategory, @controller.params[:article][:subcategory]
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
    get 'new', {:category => @category.to_param, :subcategory => @subcategory.to_param}.merge(cancel), with_user
  end
  
  def post_create(options={})
    @subcategory = categories(:sub1)
    @article = {
      :name => 'Testy',
      :description => 'Testy is used for testing pruposes.',
      :price => '11,11',
      :article_number => '12345.6',
      :subcategory_id => @subcategory.id}
    @article[:name] = '' if options[:with] == :errors
    @html_id = articles(:one).html_id
    post 'create', {:article => @article, :html_id => @html_id}, with_user
  end
end
