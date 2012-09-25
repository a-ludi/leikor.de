# -*- encoding : utf-8 -*-
require 'test_helper'

module SslRequirements
  class SessionsControllerTest < ActionController::TestCase
    test_tested_files_checksum(
      ['app/controllers/sessions_controller.rb', 'bd25db0a86cdc475ba5dda6ba0daaa13'],
      ['config/routes.rb', 'fc70545d8376feb442ad4df1ef94556f']
    )
    
    test "ssl requirements without user" do
      assert_ssl_required { get 'new' }
      assert_ssl_required { post 'create' }
      assert_ssl_required { get 'destroy' }
    end
    
    test "ssl requirements with user" do
      assert_ssl_required { get 'new', {}, with_user }
      assert_ssl_required { post 'create', {}, with_user }
      assert_ssl_required { get 'destroy', {}, with_user }
    end
  end
end
