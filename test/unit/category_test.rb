# -*- encoding : utf-8 -*-
require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test "default_scope" do
    assert_equal categories(:super_fst, :super, :sub2, :sub1), Category.all
  end
  
  test "named_scope is_a_category" do
    Category.is_a_category.all.each do |category|
      assert_equal Category, category.class
    end
  end

  test "type should be nil" do
    assert_nil categories(:super)[:type]
  end
  
  test "should have subcategories" do
    assert_equal 2, categories(:super).subcategories.length
  end
  
  test "subcategories should be ordered by ord" do
    assert_equal categories(:sub2), categories(:super).subcategories[0]
    assert_equal categories(:sub1), categories(:super).subcategories[1]
  end
  
  test "should have articles" do
    assert_equal 5, categories(:super).articles.length
  end
  
  test "articles should be ordered by ord" do
    assert_equal(articles(:one, :five, :four, :three, :two),
      categories(:super).articles)
  end
  
  test "should have a name" do
    categories(:super).name = ''
    assert_errors_on categories(:super), :on => :name
  end
  
  test "should have a ord" do
    categories(:super).ord = nil
    assert_errors_on categories(:super), :on => :ord
  end
  
  test "should have a numerical ord" do
    categories(:super).ord = 'first'
    assert_errors_on categories(:super), :on => :ord
  end
  
  test "should have a ord >= 0" do
    categories(:super).ord = -1
    assert_errors_on categories(:super), :on => :ord
  end
  
  test "should have a integral ord" do
    categories(:super).ord = 1.5
    assert_errors_on categories(:super), :on => :ord
  end
  
  test "human_name should be a string" do
    assert_instance_of String, Category.human_name
  end
  
  test "to_param has correct format" do
    assert_exact_match Category::PARAM_FORMAT, categories(:super).to_param
  end
  
  test "to_param translates special chararacters" do
    c = categories(:super)
    c.name = 'Südhärbeßt & Söhne'
    assert_equal("#{Fixtures.identify :super}-suedhaerbesst-und-soehne",
      c.to_param)
  end
  
  test "::from_param returns correct record" do
    assert_equal(categories(:super),
      Category.from_param(categories(:super).to_param))
    assert_equal(categories(:sub1),
      Category.from_param(categories(:sub1).to_param))
  end
  
  test "url_hash includes neccessary fields" do
    assert_includes categories(:super).url_hash, :category
  end
  
  test "url_hash includes correct values" do
    assert_equal(Hash[:category => categories(:super).to_param],
      categories(:super).url_hash)
  end
  
  test "url_hash propagates custom options" do
    url_hash = categories(:super).url_hash(:custom_key => :custom_value)
    assert_includes url_hash, :custom_key
    assert_equal :custom_value, url_hash[:custom_key]
  end

  test "html ids are unique" do
    assert categories(:super).html_id != categories(:sub1).html_id
    assert categories(:super).html_id != categories(:sub2).html_id
    assert categories(:sub1).html_id != categories(:sub2).html_id
  end
  
  test "overview returns at most 4 articles" do
    c = categories(:sub1)
    for i in 1..6
      c.articles.new :name => 'name', :description => 'desc', :price => 1.0,
        :article_number => "12345.#{i}"
    end
    assert c.overview.length <= 4
  end
  
  test "overview returns no duplicates" do
    c = categories(:sub1)
    assert_items_unique c.overview, :not_empty => true
  end
  
  test "::next_ord should return highest_ord + 1" do
    assert_equal 3, Category.next_ord
  end
  
  test "next_subcategory_ord should return highest_ord + 1" do
    assert_equal 5, categories(:super).next_subcategory_ord
    assert_equal 0, categories(:super_fst).next_subcategory_ord
  end
end
