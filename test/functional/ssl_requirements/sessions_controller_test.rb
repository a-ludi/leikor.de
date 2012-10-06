# -*- encoding : utf-8 -*-
require 'test_helper'

module SslRequirements
  class SessionsControllerTest < ActionController::TestCase
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
