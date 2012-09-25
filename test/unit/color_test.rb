# -*- encoding : utf-8 -*-
require 'test_helper'

class ColorTest < ActiveSupport::TestCase
  test_tested_files_checksum 'e6f1779ffe82fed16356710d48164019'
  
  test "should have a unique label" do
    colors(:green).label = 'red'
    assert_errors_on colors(:green), :on => :label
    
    colors(:red).label = nil
    assert_errors_on colors(:red), :on => :label
  end

  test "should have a hex code with correct format" do
    colors(:green).hex = 'invalid_hex_code'
    assert_errors_on colors(:green), :on => :hex
    
    colors(:red).hex = nil
    assert_errors_on colors(:red), :on => :hex
  end
end
