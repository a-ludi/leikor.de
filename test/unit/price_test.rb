require 'test_helper'

class PriceTest < ActiveSupport::TestCase
  def setup
    @price = prices(:one_first)
    @article = articles(:one)
  end
  
  test "should be ordered by amount ASC" do
    assert_equal prices(
      :five_only,
      :four_only,
      :three_only,
      :two_only,
      :one_third,
      :one_second,
      :one_first
    ), Price.all
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
end
