require 'test_helper'

class Categorytest < ActiveSupport::TestCase
  test "type should be nil" do
    assert_nil categories(:super)[:type]
  end
  
  test "should have subcategories" do
    assert_equal 2, categories(:super).subcategories.length
  end
  
  test "subcategories should be ordered alphabetically" do
    assert_equal categories(:super).subcategories[0], categories(:sub1)
    assert_equal categories(:super).subcategories[1], categories(:sub2)
  end
  
  test "should have articles" do
    assert_equal 5, categories(:super).articles.length
  end
  
  test "articles should be ordered alphabetically" do
    assert_equal categories(:super).articles, articles(:one, :three, :two, :five, :four)
  end
  
  TEST_CATEGORY_HASH = {:name => 'Einzigartige Kategorie'}
  test "save succeeds with TEST_CATEGORY_HASH" do
    assert_creates_record_from Category, TEST_CATEGORY_HASH
  end
  
  test "record invalid without name" do
    c = Category.create TEST_CATEGORY_HASH.merge(:name => '')
    assert_errors_on c, :on => :name
  end
  
  test "record invalid with non-unique name" do
    c = Category.create TEST_CATEGORY_HASH.merge(:name => categories(:super).name)
    assert_errors_on c, :on => :name
    c = Category.create TEST_CATEGORY_HASH.merge(:name => categories(:sub1).name)
    assert_errors_on c, :on => :name
  end
  
  test "human_name returns String" do
    assert_instance_of String, Category.human_name
  end
  
  test "to_param has correct format" do
    assert_exact_match Category::PARAM_FORMAT, categories(:super).to_param
  end
  
  test "to_param translates special chararacters" do
    c = categories(:super)
    c.name = 'Südhärbeßt & Söhne'
    assert_equal c.to_param, '1-suedhaerbesst-und-soehne'
  end
  
  test "self.from_param returns correct record" do
    assert_equal categories(:super), Category.from_param(categories(:super).to_param)
    assert_equal categories(:sub1), Category.from_param(categories(:sub1).to_param)
  end
  
  test "url_hash includes neccessary fields" do
    assert_includes categories(:super).url_hash, :category
  end
  
  test "url_hash includes correct values" do
    assert_equal categories(:super).url_hash, {:category => '1-super-category'}
  end
  
  test "url_hash propagates custom options" do
    url_hash = categories(:super).url_hash(:custom_key => :custom_value)
    assert_includes url_hash, :custom_key
    assert_equal url_hash[:custom_key], :custom_value
  end

  test "html ids are unique" do
    assert categories(:super).html_id != categories(:sub1)
    assert categories(:super).html_id != categories(:sub2)
    assert categories(:sub1).html_id != categories(:sub2)
  end
  
  test "overview returns at most 4 articles" do
    c = categories(:sub1)
    c.articles.new :name => 'name', :description => 'desc', :price => 1.0, :article_number => '12345.1'
    c.articles.new :name => 'name', :description => 'desc', :price => 1.0, :article_number => '12345.2'
    c.articles.new :name => 'name', :description => 'desc', :price => 1.0, :article_number => '12345.3'
    c.articles.new :name => 'name', :description => 'desc', :price => 1.0, :article_number => '12345.4'
    c.articles.new :name => 'name', :description => 'desc', :price => 1.0, :article_number => '12345.5'
    assert c.overview.length <= 4
  end
  
  test "overview returns no duplicates" do
    c = categories(:sub1)
    assert_items_unique c.overview, :not_empty => true
  end
end
