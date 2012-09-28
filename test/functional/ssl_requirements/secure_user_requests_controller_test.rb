require 'test_helper'

module SslRequirements
  class SecureUserRequestsControllerTest < ActionController::TestCase
    tests SecureUserRequestsController
    test_tested_files_checksum(
      ['app/controllers/secure_user_requests_controller.rb', '0cbda0cf4a90fae952ccdd5316535d97'],
      ['config/routes.rb', 'fc70545d8376feb442ad4df1ef94556f']
    )
    
    def setup
      @id = secure_user_requests(:max_confirm).to_param
    end
    
    test "ssl requirements without user" do
      assert_ssl_required { get 'new', :type => 'SecureUserRequest::ResetPassword' }
      assert_ssl_required { post 'create', :type => 'SecureUserRequest::ConfirmRegistration' }
      assert_ssl_required { post 'create' }
      assert_ssl_required { post 'create', :format => 'js' }
      assert_ssl_required { get 'edit', :id => @id }
      assert_ssl_required { get 'edit', :id => @id, :format => 'js' }
      assert_ssl_required { get 'destroy', :id => @id }
      assert_ssl_required { get 'destroy', :id => @id, :format => 'js' }
      assert_ssl_required { put 'update', :id => @id }
      assert_ssl_required { put 'update', :id => @id, :format => 'js' }
      assert_ssl_required { delete 'destroy', :id => @id }
      assert_ssl_required { delete 'destroy', :id => @id, :format => 'js' }
    end
    
    test "ssl requirements with user" do
      assert_ssl_required { get 'new', {:type => 'SecureUserRequest::ResetPassword'}, with_user }
      assert_ssl_required { post 'create', {:type => 'SecureUserRequest::ConfirmRegistration'}, with_user }
      assert_ssl_required { post 'create', with_user }
      assert_ssl_required { post 'create', {:format => 'js'}, with_user }
      assert_ssl_required { get 'edit', {:id => @id}, with_user }
      assert_ssl_required { get 'edit', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { get 'destroy', {:id => @id}, with_user }
      assert_ssl_required { get 'destroy', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { put 'update', {:id => @id}, with_user }
      assert_ssl_required { put 'update', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @id}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @id, :format => 'js'}, with_user }
    end
  end
end
