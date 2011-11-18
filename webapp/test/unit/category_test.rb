require 'test_helper'

class Categorytest < ActiveSupport::TestCase
  test "type should be nil" do
    assert_nil categories(:super)[:type]
  end
  
  test "should have subcategories" do
    assert_equal 2, categories(:super).subcategories.length
  end
  
  test "subcategories should be ordered alphabetically" do
    assert_equal categories(:sub1), categories(:super).subcategories[0]
    assert_equal categories(:sub2), categories(:super).subcategories[1]
  end
  
  test "should have articles" do
    assert_equal 5, categories(:super).articles.length
  end
  
  test "articles should be ordered alphabetically" do
    assert_equal(articles(:one, :three, :two, :five, :four),
      categories(:super).articles)
  end
  
  test "save succeeds with test hash" do
    assert_creates_record_from Category, {:name => 'Einzigartige Kategorie'}
  end
  
  test "record invalid without name" do
    categories(:super).name = ''
    assert_errors_on categories(:super), :on => :name
  end
  
  test "record invalid with non-unique name" do
    categories(:super).name = categories(:sub1).name
    assert_errors_on categories(:super), :on => :name
    
    categories(:sub1).name = categories(:sub2).name
    assert_errors_on categories(:sub1), :on => :name
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
    assert_equal("#{Fixtures.identify :super}-suedhaerbesst-und-soehne",
      c.to_param)
  end
  
  test "self.from_param returns correct record" do
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
end
