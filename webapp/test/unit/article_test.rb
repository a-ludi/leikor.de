require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "should have a subcategory" do
    articles.each {|a| assert_equal categories(:sub1), a.subcategory}
  end
  
  test "should return default picture url" do
    assert_equal '/images/picture/original/dummy.png', articles(:one).picture.url
  end
  
  test "html_id returns string" do
    assert_equal String, articles(:one).html_id.class
  end
  
  test "html ids are unique" do
    for a in articles
      for b in articles
        assert a.html_id != b.html_id unless a == b
      end
    end
  end
  
  test "url_hash includes neccessary fields" do
    assert_includes articles(:one).url_hash, :category, :subcategory, :article
  end
  
  test "url_hash includes correct values" do
    a = articles(:one)
    assert_equal(Hash[:category => a.subcategory.category.to_param,
      :subcategory => a.subcategory.to_param, :article => a.article_number],
      articles(:one).url_hash)
  end
  
  test "url_hash propagates custom options" do
    url_hash = articles(:one).url_hash(:custom_key => :custom_value)
    assert_includes url_hash, :custom_key
    assert_equal :custom_value, url_hash[:custom_key]
  end
  
  test "format price has correct format" do
    articles(:one).price = 24.57
    assert_equal '24,57', articles(:one).format(:price)
  end
end
