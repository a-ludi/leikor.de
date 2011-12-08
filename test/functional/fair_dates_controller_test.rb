require 'test_helper'

class FairDatesControllerTest < ActionController::TestCase
  test "index action" do
    get 'index'
    
    puts '[FairDatesControllerTest] order in test_index_action is reversed'
    assert_equal fair_dates(:one, :two, :three), assigns(:fair_dates).reverse
    assert_respond_to assigns(:stylesheets), :each
    assert_non_empty_kind_of String, assigns(:title)
  end
end
