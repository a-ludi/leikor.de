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
  
  test "index action sets stylesheets" do
    get_index
    assert_respond_to assigns(:stylesheets), :each
  end
  
  test "index action sets title" do
    get_index
    assert_kind_of String, assigns(:title)
  end
  
private
  def get_index
    @subcategory = categories(:sub1)
    @category = @subcategory.category
    get 'index', {:category => @category.to_param, :subcategory => @subcategory.to_param}
  end
end
