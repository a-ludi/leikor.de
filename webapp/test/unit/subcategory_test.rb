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
    assert_equal categories(:sub1).articles, articles(:one, :three, :two, :five, :four)
  end
  
  TEST_SUBCATEGORY_HASH = {:name => 'Einzigartige Unterkategorie', :category_id => 1}
  test "save succeeds with TEST_SUBCATEGORY_HASH" do
    assert_creates_record_from Subcategory, TEST_SUBCATEGORY_HASH
  end
  
  test "record invalid without category_id" do
    c = Subcategory.create TEST_SUBCATEGORY_HASH.merge(:category_id => '')
    assert_errors_on c, :on => :category_id
  end
  
  test "human_name returns String" do
    assert_instance_of String, Subcategory.human_name
  end
  
  test "url_hash includes neccessary fields" do
    assert_includes categories(:sub1).url_hash, :category, :subcategory
  end
  
  test "url_hash includes correct values" do
    assert_equal categories(:sub1).url_hash, {:category => '1-super-category', :subcategory => '2-subcategory-a1'}
  end
  
  test "url_hash propagates custom options" do
    url_hash = categories(:sub1).url_hash(:custom_key => :custom_value)
    assert_includes url_hash, :custom_key
    assert_equal url_hash[:custom_key], :custom_value
  end
end
