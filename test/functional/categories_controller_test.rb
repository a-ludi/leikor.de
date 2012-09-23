# -*- encoding : utf-8 -*-
require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  test_tested_files_checksum 'fe5334fbfda3223856f903b6f353b02d'

  test "ssl requirements" do
    @subcategory = categories(:sub1).to_param
    @category = categories(:sub1).category.to_param

    assert_ssl_denied { get 'index' }
    assert_ssl_denied { get 'subindex', :category => @category }
    assert_ssl_denied { get 'ask_destroy', :category => @category }
    assert_ssl_denied { get 'ask_destroy', :category => @category, :subcategory => @subcategory }
    assert_ssl_denied { post 'create' }
    assert_ssl_denied { get 'new' }
    assert_ssl_denied { get 'edit', :id => @subcategory }
    assert_ssl_denied { put 'update', :id => @subcategory }
    assert_ssl_denied { delete 'destroy', :id => @subcategory }
    assert_ssl_denied { post 'reorder' }
  end
  
  test "login required for new create edit update ask_destroy destroy reorder" do
    [:new, :create, :edit, :update, :ask_destroy, :destroy, :reorder].each do |action|
      assert_before_filter_applied :employee_required, action
    end
  end
  
  test "categories fetched before index subindex" do
    [:index, :subindex].each do |action|
      assert_before_filter_applied :fetch_categories, action
    end
  end
  
  test "updates last updated after create update destroy reorder" do
    [:create, :update, :destroy, :reorder].each do |action|
      assert_after_filter_applied :save_updated_at, action
    end
  end
  
  test "index action" do
    get 'index'
    
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
    assert_present assigns(:scroll_target)
  end
  
  test "subindex action" do
    get 'subindex', {:category => categories(:super).to_param}
    
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
    assert_present assigns(:scroll_target)
  end
  
  test "new action" do
    https!
    get 'new', {}, with_user
    
    assert_kind_of Category, assigns(:category)
    assert_includes assigns(:category).name, Category.human_name
    assert_present assigns(:html_id)
    refute assigns(:cancel)
  end
  
  test "new action with subcategory" do
    https!
    get 'new', {:category_id => categories(:super).to_param}, with_user
    
    assert_equal Subcategory, assigns(:category).class
    assert_includes assigns(:category).name, Subcategory.human_name
    assert_present assigns(:html_id)
    refute assigns(:cancel)
  end
  
  test "create action" do
    create_category
    
    assert_kind_of Category, assigns(:category)
    assert_equal @html_id, assigns(:html_id)
    assert_equal 'category', assigns(:partial)
    assert_template 'edit'
  end
  
  test "create action for subcategory" do
    create_subcategory
    
    assert_equal Subcategory, assigns(:category).class
    assert_equal @html_id, assigns(:html_id)
    assert_equal 'category', assigns(:partial)
    assert_template 'edit'
  end
  
  test "create action with errors" do
    create_category :with => :errors
    
    assert_equal Category, assigns(:category).class
    assert_equal @html_id, assigns(:html_id)
    assert_equal 'form', assigns(:partial)
    assert_template 'edit'
  end
  
  test "edit action" do
    https!
    get 'edit', {:id => categories(:super).to_param}, with_user
    
    assert_kind_of Category, assigns(:category)
    assert_equal 'form', assigns(:partial)
  end
  
  test "edit action on cancel" do
    https!
    get 'edit', {:id => categories(:super).to_param, :cancel => true}, with_user
    
    assert_equal 'category', assigns(:partial)
  end
  
  test "update action" do
    update_category
    
    assert_equal 'category', assigns(:partial)
    assert_equal @category.id, flash[:saved_category_id]
    assert_template 'edit'
  end
  
  test "update action with errors" do
    update_category :with => :errors
    
    assert_equal 'form', assigns(:partial)
    assert_template 'edit'
  end
  
  test "ask_destroy action" do
    ask_destroy_category
    
    assert_kind_of Category, assigns(:category)
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
  end
    
  test "ask_destroy action gets subcategory" do
    ask_destroy_subcategory
    
    assert_kind_of Subcategory, assigns(:category)
  end

  test "destroy action" do
    destroy_category
    
    assert_kind_of Category, assigns(:category)
    assert assigns(:category).destroyed?
    refute Category.exists?(@category.id)
    refute_empty flash[:message]
    assert_redirected_to categories_path
  end
  
  test "destroy action with subcategory" do
    destroy_subcategory
    
    assert_redirected_to category_path(@category.category.url_hash)
  end
  
  test "reorder action categories" do
    @categories_list = categories(:super, :super_fst).collect {|a| a.id}
    
    https!
    post 'reorder', {:categories_list => @categories_list}, with_user
    
    @new_categories_list = Category.find_all_by_type(nil, :order => "ord ASC").collect {|c| c.id}
    assert_equal @categories_list, @new_categories_list
  end
  
  test "reorder action subcategories" do
    @subcategories_list = categories(:sub1, :sub2).collect {|a| a.id}
    
    https!
    post 'reorder', {:subcategories_list => @subcategories_list}, with_user
    
    @new_subcategories_list = Category.find_all_by_type('Subcategory', :order => "ord ASC").collect {|c| c.id}
    assert_equal @subcategories_list, @new_subcategories_list
  end
  
  test "set_random_html_id_or_take_from_param passes html_id from params" do
    html_id = 'not_generated'
    https!
    get 'new', {:html_id => html_id}, with_user
    
    @controller.send(:set_random_html_id_or_take_from_param)
    
    assert_equal html_id, assigns(:html_id)
  end
  
  test "set_random_html_id_or_take_from_param sets unique html_id" do
    assert_items_unique 1..5 do
      https!
      get 'new', {}, with_user
      @controller.send(:set_random_html_id_or_take_from_param)
    end
  end
  
  test "create_sub_or_category_from_params sets category to category" do
    create_category
    assert_kind_of Category, assigns(:category)
    refute_kind_of Subcategory, assigns(:category)
  end
  
  test "create_sub_or_category_from_params sets category to subcategory" do
    create_subcategory
    assert_kind_of Subcategory, assigns(:category)
  end
  
  test "update_sub_or_category_from_params sets category" do
    update_category
    @controller.send(:update_sub_or_category_from_params)
    assert_kind_of Category, assigns(:category)
    refute_kind_of Subcategory, assigns(:category)
  end

  test "update_sub_or_category_from_params sets subcategory" do
    update_category :label => :sub1
    @controller.send(:update_sub_or_category_from_params)
    assert_kind_of Subcategory, assigns(:category)
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
    refute @controller.send(:update_sub_or_category_from_params)
  end

  test "fetch_sub_or_category_from_params sets category to category" do
    ask_destroy_category
    assert_kind_of Category, assigns(:category)
  end
  
  test "fetch_sub_or_category_from_params sets category to subcategory" do
    ask_destroy_subcategory
    assert_kind_of Subcategory, assigns(:category)
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
    create_sub_or_category Hash[:category => {:id => nil, :name => 'New Category', :ord => 99}], options
  end
  
  def create_subcategory(options={})
    create_sub_or_category Hash[:subcategory => {:id => nil, :name => 'New Category',
        :category_id => categories(:super).id, :ord => 99}], options
  end
  
  def update_category(options={})
    @category = categories(options[:label] || :super)
    params = {:category => {:name => "New Category Name"}, :id => @category}
    params[:category][:name] = '' if options[:with] == :errors
    
    https!
    put 'update', params, with_user
  end
  
  def create_sub_or_category(category, options={})
    category.first[1][:name] = '' if options[:with] == :errors
    @category = category.first
    @html_id = 'not_generated'
    params = {:html_id => @html_id}.merge category
    
    https!
    post 'create', params, with_user
  end
  
  def ask_destroy_category
    @category = categories(:super)
    
    https!
    get 'ask_destroy', {:category => @category.to_param}, with_user
  end
  
  def ask_destroy_subcategory
    @category = categories(:sub1)
    
    https!
    get('ask_destroy', {:category => @category.category.to_param,
        :subcategory => @category.to_param}, with_user)
  end
  
  def destroy_category(category_label=:super)
    @category = categories(category_label)
    
    https!
    delete 'destroy', {:id => @category.to_param}, with_user
  end
  
  def destroy_subcategory
    destroy_category :sub1
  end
end
