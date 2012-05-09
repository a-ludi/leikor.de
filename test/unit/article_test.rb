# -*- encoding : utf-8 -*-
require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "should have a name" do
    articles(:one).name = ''
    assert_errors_on articles(:one), :on => :name
  end
  
  test "should have a price" do
    articles(:one).price = ''
    assert_errors_on articles(:one), :on => :price
  end
  
  test "should have a article number" do
    articles(:one).article_number = ''
    assert_errors_on articles(:one), :on => :article_number
  end
  
  test "should have a subcategory" do
    articles(:one).subcategory = nil
    assert_errors_on articles(:one), :on => :subcategory
  end
  
  test "should have a numeric price" do
    articles(:one).price = 'Five Dollars Fiveteen'
    assert_errors_on articles(:one), :on => :price
  end
  
  test "should have a positive price" do
    articles(:one).price = 0.0
    assert_errors_on articles(:one), :on => :price
    
    articles(:one).price = -1.0
    assert_errors_on articles(:one), :on => :price
  end
  
  test "should have a unique article number" do
    articles(:one).article_number = articles(:two).article_number
    assert_errors_on articles(:one), :on => :article_number
  end
  
  test "should have a well-formatted article number" do
    for mf_number in ['123456.1', '12345.123', 'a2345.1', '1234.12', '12345,1']
      articles(:one).article_number = mf_number
      assert_errors_on articles(:one), :on => :article_number, :message => "article number #{mf_number} is invalid"
    end
  end
  
  test "should return default picture url" do
    assert_equal '/images/picture/original/dummy.png', articles(:one).picture.url
  end
  
  test "html_id returns string" do
    assert_equal String, articles(:one).html_id.class
  end
  
  test "html ids are unique" do
    assert_items_unique Article.find(:all), :not_empty => true do |a|
      a.html_id
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
  
  test "format :price has correct format" do
    articles(:one).price = 24.57
    assert_equal '24,57', articles(:one).format(:price)
  end
  
  test "description should be marked up with maruku" do
    assert_equal articles(:one).description,
      "<p>This <em>is a</em> <strong>marked up</strong> description!</p>"
  end
end
