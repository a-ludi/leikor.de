# -*- encoding : utf-8 -*-
require 'test_helper'

class SecureUserRequestTest < ActiveSupport::TestCase
  test_tested_files_checksum(
    ['app/models/secure_user_request.rb', 'fd622c7fbabbb32fd739875246541c64'],
    ['app/models/secure_user_request/confirm_registration.rb', '5007df50220c2999d93fa72bef0d05ea'],
    ['app/models/secure_user_request/reset_password.rb', '73bbe4396bc5f452a476c19dd16ed2b9']
  )

  test "should belong to user" do
    assert_equal secure_user_requests(:max_confirm).user, users(:maxi)
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
