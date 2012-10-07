require 'test_helper'

class PriceTest < ActiveSupport::TestCase
  def setup
    @price = prices(:one_first)
    @article = articles(:one)
  end
  
  test "should be ordered by amount DESC" do
    assert_equal prices(:one_first, :one_second, :one_third, :two_only, :three_only, :four_only,
        :five_only), Price.all
  end
  
  test "should have a article" do
    assert_no_errors_on @price, :on => :article
    @price.article = nil
    assert_errors_on @price, :on => :article
  end
  
  test "amount should be positive" do
    assert_no_errors_on @price, :on => :amount
    
    @price.amount = 0.0
    assert_errors_on @price, :on => :amount
    
    @price.amount = -10.0
    assert_errors_on @price, :on => :amount
  end
  
  test "minimum_count should be integer" do
    assert_no_errors_on @price, :on => :minimum_count
    @price.minimum_count = 3.5
    assert_errors_on @price, :on => :minimum_count
  end
  
  test "minimum_count should be at least zero" do
    @price.minimum_count = 0
    assert_no_errors_on @price, :on => :minimum_count
    
    @price.minimum_count = -10
    assert_errors_on @price, :on => :minimum_count
  end
  
  test "minimum_count should be unique per article" do
    @article.prices.clear
    @prices = 2.times.map {|n| @article.prices.create :amount => 10.0+n, :minimum_count => 10 }
    
    assert_errors_on @prices.last, :on => :minimum_count
    assert_errors_on @article, :on => 'prices.minimum_count'
  end
  
  test "amount should be unique per article" do
    @article.prices.clear
    @prices = 2.times.map {|n| @article.prices.create :amount => 10.0, :minimum_count => 10*n }
    
    assert_errors_on @prices.last, :on => :amount
    assert_errors_on @article, :on => 'prices.amount'
  end
  
  test "rising minimum_count should mean falling amount" do
    @article.prices.clear
    @prices = 2.times.map {|n| @article.prices.create :amount => 10.0 - n, :minimum_count => n }
    
    refute_errors_on @prices.last
    refute_errors_on @article, :on => :prices
    
    @article.prices.clear
    @prices = 2.times.map {|n| @article.prices.create :amount => 10.0 + 10.0*n, :minimum_count => 10*n }
    
    assert_errors_on @prices.last
  end  
end
