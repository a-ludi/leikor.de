# -*- encoding : utf-8 -*-

require 'test_helper'

class SecureUserRequestTest < ActiveSupport::TestCase
  # -belongs_to :user
  # -validates_presence_of :type, :user_id
  # after_validation_on_create :generate_external_id
  # -lifetime
  # -expired?
  
  test "should belong to user" do
    assert_equal secure_user_requests(:max_confirm).user, users(:max)
    assert_equal secure_user_requests(:john_reset).user, users(:john)
  end
  
  test "should have a type" do
    secure_user_requests(:max_confirm).type = nil
    
    assert_errors_on secure_user_requests(:max_confirm), :on => :type
  end
  
  test "should have a user_id" do
    secure_user_requests(:max_confirm).user_id = ''
    
    assert_errors_on secure_user_requests(:max_confirm), :on => :user_id
  end
  
  test "should get external_id after create" do
    new_request = users(:john).create_confirm_registration_request
    
    refute new_request.external_id.blank?
  end
  
  test "lifetime returns correct value" do
    assert_equal secure_user_requests(:max_confirm).lifetime, 7.days
    assert_equal secure_user_requests(:john_reset).lifetime, 3.days
  end
  
  test "expired? returns correct value" do
    secure_user_requests(:max_confirm).updated_at = Time.now - 99.days
    
    assert secure_user_requests(:max_confirm).expired?
  end
end
