# -*- encoding : utf-8 -*-

require 'test_helper'

class Subcategorytest < ActiveSupport::TestCase
  test "should have a type" do
    assert_equal 'Subcategory', categories(:sub1)[:type]
  end
  
  test "should have a category" do
    assert_equal categories(:super), categories(:sub1).category
    assert_equal categories(:super), categories(:sub2).category
  end
  
  test "should have articles" do
    assert_equal 5, categories(:sub1).articles.length
  end
  
  test "articles should be ordered y ord" do
    assert_equal(articles(:one, :five, :four, :three, :two),
      categories(:sub1).articles)
  end
  
  test "should have a category_id" do
    categories(:sub1).category_id = nil
    assert_errors_on categories(:sub1), :on => :category_id
  end
  
  test "human_name should be a string" do
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
  
  test "next_subcategory_ord should return highest_ord + 1" do
    assert_equal categories(:sub1).next_article_ord, 6
    assert_equal categories(:sub2).next_article_ord, 0
  end
end
