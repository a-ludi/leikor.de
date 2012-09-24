# -*- encoding : utf-8 -*-
require 'test_helper'

module SslRequirements
  class SessionsControllerTest < ActionController::TestCase
    test_tested_files_checksum(
      ['app/controllers/sessions_controller.rb', '7b75b8b656c562f3753abb06cceb6ecb'],
      ['config/routes.rb', 'a593e4312e018d6a068b0fb01d7ba989']
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
