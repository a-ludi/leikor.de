require 'test_helper'

class FairDateTest < ActiveSupport::TestCase
  test "record invalid without from" do
    fair_dates(:one).from = nil
    assert_errors_on fair_dates(:one), :on => :from
  end
  
  test "record invalid without to" do
    fair_dates(:one).to = nil
    assert_errors_on fair_dates(:one), :on => :to
  end
  
  test "record invalid without name" do
    fair_dates(:one).name = ''
    assert_errors_on fair_dates(:one), :on => :name
  end
end
