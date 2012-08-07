# -*- encoding : utf-8 -*-
require 'test_helper'

class FairDateTest < ActiveSupport::TestCase
  test_tested_files_checksum '3d125d42fb80370e46f49a691af60765'
  
  test "should have a from_date" do
    fair_dates(:one).from_date = nil
    assert_errors_on fair_dates(:one), :on => :from_date
  end
  
  test "should have a to_date" do
    fair_dates(:one).to_date = nil
    assert_errors_on fair_dates(:one), :on => :to_date
  end
  
  test "should have a name" do
    fair_dates(:one).name = ''
    assert_errors_on fair_dates(:one), :on => :name
  end
  
  test "should set valid date" do
    fair_dates(:one).to_date = "16.04.1991"
    fair_dates(:two).to_date = "16.4."
    fair_dates(:three).to_date = Date.new(1991, 4, 16)
    
    correct_date = Date.new(1991, 4, 16)
    correct_derived_date = Date.new(Date.today.year, 4, 16)
    correct_derived_date += 1.year  if correct_derived_date.past?
    
    assert_no_errors_on fair_dates(:one), :on => :to_date
    assert_no_errors_on fair_dates(:two), :on => :to_date
    assert_no_errors_on fair_dates(:three), :on => :to_date
     
    assert_equal fair_dates(:one).to_date, correct_date
    assert_equal fair_dates(:two).to_date, correct_derived_date
    assert_equal fair_dates(:three).to_date, correct_date 
  end
end
