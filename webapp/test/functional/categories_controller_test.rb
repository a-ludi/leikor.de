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
    assert_respond_to assigns(:stylesheets), :each
  end
  
  test "index action sets title" do
    get 'index'
    assert_kind_of String, assigns(:title)
  end
  
  test "subindex action sets stylesheets" do
    get 'subindex', {:category => categories(:super).to_param}
    assert_respond_to assigns(:stylesheets), :each
  end
  
  test "subindex action sets title" do
    get 'subindex', {:category => categories(:super).to_param}
    assert_kind_of String, assigns(:title)
  end
  
  test "new action requires login" do
    get 'new'
    assert_response :redirect
  end
  
  test "new action creates new category without category_id" do
    get 'new', {}, with_user
    assert_equal Category, assigns(:category).class
  end
  
  test "new action creates new subcategory with category_id" do
    get 'new', {:category_id => categories(:super).to_param}, with_user
    assert_equal Subcategory, assigns(:category).class
  end
  
  test "new action sets appropriate name for new category" do
    get 'new', {}, with_user
    assert_includes assigns(:category).name, Category.human_name
  end
  
  test "new action sets appropriate name for new subcategory" do
    get 'new', {:category_id => categories(:super).to_param}, with_user
    assert_includes assigns(:category).name, Subcategory.human_name
  end
  
  test "new action sets html_id" do
    get 'new', {}, with_user
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
  
  test "create action renders edit template" do
    create_category
    assert_template 'edit'
    
    create_category :with => :errors
    assert_template 'edit'
  end
  
  test "edit action sets category" do
    get 'edit', {:id => categories(:super).to_param}, with_user
    assert_kind_of Category, assigns(:category)
  end
  
  test "edit action sets form partial" do
    get 'edit', {:id => categories(:super).to_param}, with_user
    assert_equal 'form', assigns(:partial)
  end
  
  test "edit action sets category partial on cancel" do
    get 'edit', {:id => categories(:super).to_param, :cancel => true}, with_user
    assert_equal 'category', assigns(:partial)
  end
  
  test "update action sets category partial on success" do
    update_category
    assert_equal 'category', assigns(:partial)
  end
  
  test "update action sets saved_category_id on success" do
    update_category
    assert_equal @category.id, flash[:saved_category_id]
  end
  
  test "update action sets form partial on failure" do
    update_category :with => :errors
    assert_equal 'form', assigns(:partial)
  end
  
  test "update action renders edit action" do
    update_category
    assert_template 'edit'
    
    update_category :with => :errors
    assert_template 'edit'
  end
  
  test "ask_destroy action gets category" do
    ask_destroy_category
    assert_equal Category, assigns(:category).class
  end
    
  test "ask_destroy action gets subcategory" do
    ask_destroy_subcategory
    assert_equal Subcategory, assigns(:category).class
  end

  test "ask_destroy action sets stylesheets" do
    ask_destroy_category
    assert_respond_to assigns(:stylesheets), :each
  end
  
  test "ask_destroy action sets title" do
    ask_destroy_category
    assert_kind_of String, assigns(:title)
  end
  
  test "destroy action gets category" do
    destroy_category
    assert_kind_of Category, assigns(:category)
  end
  
  test "destroy action destroys category" do
    destroy_category
    assert assigns(:category).frozen?
    assert ! Category.exists?(@category.id)
  end
  
  test "destroy action sets flash message" do
    destroy_category
    assert_not_empty flash[:message]
  end
  
  test "destroy action redirects to categories after category deleted" do
    destroy_category
    assert_redirected_to categories_path
  end
  
  test "destroy action redirects to category after subcategory deleted" do
    destroy_subcategory
    assert_redirected_to category_path(@category.category.url_hash)
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
  
  test "create_sub_or_category_from_params sets category to category" do
    create_category
    assert_equal Category, assigns(:category).class
  end
  
  test "create_sub_or_category_from_params sets category to subcategory" do
    create_subcategory
    assert_equal Subcategory, assigns(:category).class
  end
  
  test "update_sub_or_category_from_params sets category" do
    update_category
    @controller.send(:update_sub_or_category_from_params)
    assert_equal Category, assigns(:category).class
  end

  test "update_sub_or_category_from_params sets subcategory" do
    update_category :label => :sub1
    @controller.send(:update_sub_or_category_from_params)
    assert_equal Subcategory, assigns(:category).class
  end

  test "update_sub_or_category_from_params updates attributes on category" do
    update_category
    @controller.send(:update_sub_or_category_from_params)
    assert_equal 'New Category Name', assigns(:category).name
  end

  test "update_sub_or_category_from_params updates attributes on subcategory" do
    update_category :label => :sub1
    @controller.send(:update_sub_or_category_from_params)
    assert_equal 'New Category Name', assigns(:category).name
  end

  test "update_sub_or_category_from_params returns true without errors" do
    update_category
    assert @controller.send(:update_sub_or_category_from_params)
  end

  test "update_sub_or_category_from_params returns false with errors" do
    update_category :with => :errors
    assert ! @controller.send(:update_sub_or_category_from_params)
  end

  test "fetch_sub_or_category_from_params sets category to category" do
    ask_destroy_category
    assert_equal Category, assigns(:category).class
  end
  
  test "fetch_sub_or_category_from_params sets category to subcategory" do
    ask_destroy_subcategory
    assert_equal Subcategory, assigns(:category).class
  end
  
  test "do_for_sub_or_category calls if_category" do
    get 'index', {:category => categories(:super).to_param}
    assert @controller.send(:do_for_sub_or_category, Proc.new{true}, Proc.new{false})
  end
  
  test "do_for_sub_or_category calls if_subcategory" do
    [{:subcategory => categories(:sub1).to_param}, {:category => categories(:super).to_param,
        :subcategory => categories(:sub1).to_param}].each do |param|
      get 'index', param
      assert @controller.send(:do_for_sub_or_category, Proc.new{false}, Proc.new{true})
    end
  end
  
  test "do_for_sub_or_category raises error" do
    assert_raises ActionController::ActionControllerError do
      get 'index'
      @controller.send(:do_for_sub_or_category, Proc.new{}, Proc.new{})
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
  
  def update_category(options={})
    @category = categories(options[:label] || :super)
    params = {:category => {:name => "New Category Name"}, :id => @category}
    params[:category][:name] = '' if options[:with] == :errors
    put 'update', params, with_user
  end
  
  def create_sub_or_category(category, options={})
    category.first[1][:name] = '' if options[:with] == :errors
    @category = category.first
    @html_id = 'not_generated'
    params = {:html_id => @html_id}.merge category
    post 'create', params, with_user
  end
  
  def ask_destroy_category
    @category = categories(:super)
    get 'ask_destroy', {:category => @category.to_param}, with_user
  end
  
  def ask_destroy_subcategory
    @category = categories(:sub1)
    get('ask_destroy', {:category => @category.category.to_param,
        :subcategory => @category.to_param}, with_user)
  end
  
  def destroy_category(category_label=:super)
    @category = categories(category_label)
    delete 'destroy', {:id => @category.to_param}, with_user
  end
  
  def destroy_subcategory
    destroy_category :sub1
  end
end
