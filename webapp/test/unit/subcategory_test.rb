require 'test_helper'

class Subcategorytest < ActiveSupport::TestCase
  test "type should be set" do
    assert_equal 'Subcategory', categories(:sub1)[:type]
  end
  
  test "should have a category" do
    assert_equal categories(:super), categories(:sub1).category
    assert_equal categories(:super), categories(:sub2).category
  end
  
  test "should have articles" do
    assert_equal 5, categories(:sub1).articles.length
  end
  
  test "articles should be ordered alphabetically" do
    assert_equal(articles(:one, :three, :two, :five, :four),
      categories(:sub1).articles)
  end
  
  test "save succeeds with test hash" do
    assert_creates_record_from(Subcategory, {:name =>
      'Einzigartige Unterkategorie', :category_id => 1})
  end
  
  test "record invalid without category_id" do
    categories(:sub1).category_id = nil
    assert_errors_on categories(:sub1), :on => :category_id
  end
  
  test "human_name returns String" do
    assert_instance_of String, Subcategory.human_name
  end
  
  test "url_hash includes neccessary fields" do
    assert_includes categories(:sub1).url_hash, :category, :subcategory
  end
  
  test "url_hash includes correct values" do
    assert_equal(Hash[:category => categories(:sub1).category.to_param,
      :subcategory => categories(:sub1).to_param], categories(:sub1).url_hash)
  end
  
  test "url_hash propagates custom options" do
    url_hash = categories(:sub1).url_hash(:custom_key => :custom_value)
    assert_includes url_hash, :custom_key
    assert_equal :custom_value, url_hash[:custom_key]
  end
end
