require 'test_helper'

class FairDateTest < ActiveSupport::TestCase
  test "record invalid without from" do
  	skip("FIXME setting from_date is weird")
    fair_dates(:one).from_date = nil
    assert_errors_on fair_dates(:one), :on => :from_date
  end
  
  test "record invalid without to" do
  	skip("FIXME setting to_date is weird")
    fair_dates(:one).to_date = nil
    assert_errors_on fair_dates(:one), :on => :to_date
  end
  
  test "record invalid without name" do
    fair_dates(:one).name = ''
    assert_errors_on fair_dates(:one), :on => :name
  end
end
