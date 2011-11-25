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
  
  test "categories fetched before index" do
    assert_before_filter_applied :fetch_categories, @controller, :index
  end
  
  test "categories fetched before subindex" do
    assert_before_filter_applied :fetch_categories, @controller, :subindex
  end
  
  test "updates last updated after create" do
    assert_after_filter_applied :save_updated_at, @controller, :create
  end
  
  test "updates last updated after update" do
    assert_after_filter_applied :save_updated_at, @controller, :update
  end
  
  test "updates last updated after destroy" do
    assert_after_filter_applied :save_updated_at, @controller, :destroy
  end
  
  test "index action sets stylesheets" do
    get 'index'
    assert_not_nil assigns(:stylesheets)
    assert_respond_to assigns(:stylesheets), :each
  end
  
  test "index action sets title" do
    get 'index'
    assert_not_nil assigns(:title)
    assert_kind_of String, assigns(:title)
  end
  
  test "subindex action sets stylesheets" do
    get 'subindex', {:category => categories(:super).to_param}
    assert_not_nil assigns(:stylesheets)
    assert_respond_to assigns(:stylesheets), :each
  end
  
  test "subindex action sets title" do
    get 'subindex', {:category => categories(:super).to_param}
    assert_not_nil assigns(:title)
    assert_kind_of String, assigns(:title)
  end
  
  test "new action requires login" do
    get 'new'
    assert_response :redirect
  end
  
  test "new action creates new category without category_id" do
    get 'new', {}, with_user
    assert_not_nil assigns(:category)
    assert_equal Category, assigns(:category).class
  end
  
  test "new action creates new subcategory with category_id" do
    get 'new', {:category_id => categories(:super).to_param}, with_user
    assert_not_nil assigns(:category)
    assert_equal Subcategory, assigns(:category).class
  end
  
  test "new action sets appropriate name for new category" do
    get 'new', {}, with_user
    assert_not_nil assigns(:category).name
    assert_includes assigns(:category).name, Category.human_name
  end
  
  test "new action sets appropriate name for new subcategory" do
    get 'new', {:category_id => categories(:super).to_param}, with_user
    assert_not_nil assigns(:category).name
    assert_includes assigns(:category).name, Subcategory.human_name
  end
  
  test "new action sets html_id" do
    get 'new', {}, with_user
    assert_not_nil assigns(:html_id)
    assert_kind_of String, assigns(:html_id)
  end
  
  test "create action creates new category" do
    create_category
    assert_equal Category, assigns(:category).class
  end
  
  test "create action creates new subcategory" do
    create_subcategory
    assert_equal Subcategory, assigns(:category).class
  end
  
  test "create action passes html_id" do
    create_category
    assert_equal @html_id, assigns(:html_id)
  end
  
  test "successful create action sets partial" do
    create_category
    assert_equal 'category', assigns(:partial)
  end
  
  test "failed create action sets partial" do
    create_category :with => :errors
    assert_equal 'form', assigns(:partial)
  end
  
  test "failed create action sets errors_occurred flag" do
    create_category :with => :errors
    assert flash[:errors_occurred]
  end
  
  test "create action renders edit template" do
    create_category
    assert_template 'edit'
    
    create_category :with => :errors
    assert_template 'edit'
  end
  
  test "edit action sets category" do
    get 'edit'
    assert_not_nil assigns(:category)
    assert_kind_of Category, assigns(:category)
  end
  
  test "edit action sets form partial" do
    get 'edit'
    assert_equal 'form', assigns(:partial)
  end
  
  test "edit action sets category partial on cancel" do
    get 'edit', {:cancel => true}
    assert_equal 'category', assigns(:partial)
  end
  
  test "set_random_html_id_or_take_from_param passes html_id from params" do
    html_id = 'not_generated'
    get 'new', {:html_id => html_id}, with_user
    assert_equal html_id, @controller.send(:set_random_html_id_or_take_from_param)
  end
  
  test "set_random_html_id_or_take_from_param sets unique html_id" do
    assert_items_unique 1..5 do
      get 'new', {}, with_user
      @controller.send(:set_random_html_id_or_take_from_param)
    end
  end

private

  def create_category(options={})
    create_sub_or_category Hash[:category => {:id => nil, :name => 'New Category'}], options
  end
  
  def create_subcategory(options={})
    create_sub_or_category Hash[:subcategory => {:id => nil, :name => 'New Category',
        :category_id => categories(:super).id}], options
  end
  
  def create_sub_or_category(category, options={})
    category.first[1][:name] = '' if options[:with] == :errors
    @category = category.first
    @html_id = 'not_generated'
    params = {:html_id => @html_id}.merge category
    post 'create', params, with_user
  end
end
