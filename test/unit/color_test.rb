# -*- encoding : utf-8 -*-
require 'test_helper'

class ColorTest < ActiveSupport::TestCase
  test_tested_files_checksum '59ee0dfa16097dae213df258d5c6e0c8'
  
  def setup
    @color = colors(:green)
  end
  
  test "should be ordered by label ASC" do
    assert_equal colors(:blue, :green, :red), Color.all
  end
  
  test "should have a unique label" do
    @color.label = 'red'
    assert_errors_on @color, :on => :label
    
    @color = colors(:red)
    @color.label = nil
    assert_errors_on @color, :on => :label
  end

  test "should have a hex code with correct format" do
    @color.hex = 'invalid_hex_code'
    assert_errors_on @color, :on => :hex
    
    @color = colors(:red)
    @color.hex = nil
    assert_errors_on @color, :on => :hex
  end
  
  test "should have many articles" do
    assert_present @color.articles
  end

  test "articles are only added once" do
    assert_equal @color.articles, @color.articles << articles(:one)
  end
end
