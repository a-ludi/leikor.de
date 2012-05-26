# -*- encoding : utf-8 -*-

require 'test_helper'

class AppDataTest < ActiveSupport::TestCase
  test "record invalid with non-unique name" do
    app_datas(:string).name = app_datas(:fixnum).name
    assert_errors_on app_datas(:string), :on => :name
  end
  
  test "record invalid with unknown data type" do
    app_datas(:string).data_type = 'UnknownClass'
    assert_errors_on app_datas(:string), :on => :data_type
  end
  
  test "should return nil if name is unknown" do
    assert_nil AppData[:unknown]
  end
  
  test "returns type-casted value" do
    assert_equal String, AppData[:string].class
    assert_equal Fixnum, AppData[:fixnum].class
    assert_equal Float, AppData[:float].class
    assert_equal Time, AppData[:time].class
  end
  
  test "creates new record on assigment" do
    AppData[:new_name] = 42
    assert_not_nil AppData.find_by_name 'new_name'
  end
  
  test "value is saved as string" do
    AppData[:fixnum] = 42
    assert_equal '42', app_datas(:fixnum).value
  end
  
  test "data type is saved as string" do
    AppData[:fixnum] = 42.23
    assert_equal 'Float', app_datas(:fixnum).data_type
  end
  
  test "record is saved after assignment" do
    AppData[:fixnum] = 436
    assert_equal '436', AppData.find_by_name('fixnum').value
  end
  
  test "raises error on invalid data type" do
    assert_raises ActiveRecord::RecordInvalid do
      AppData[:string] = ['invalid', 'data', 'type']
    end
  end
  
  test "returns the same value which was saved" do
    value = 3.14159265
    AppData[:float] = value
    assert_equal value, AppData[:float]
  end
  
  test "raises error on casting to unknown type" do
    app_datas(:string).data_type = 'UnknownClass'
    assert_raises ActiveRecord::RecordInvalid do
      AppData.send :type_casted, app_datas(:string)
    end
  end
end
