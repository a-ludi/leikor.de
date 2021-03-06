# -*- encoding : utf-8 -*-
require 'test_helper'

module SslRequirements
  class StaticControllerTest < ActionController::TestCase
    test "ssl requirements without user" do
      assert_ssl_allowed { get 'show', :path => 'kontakt' }
      refute_ssl_required { get 'show', :path => 'kontakt' }
      assert_ssl_allowed { get 'stylesheet', :path => 'layout.css' }
      refute_ssl_required { get 'stylesheet', :path => 'layout.css' }
    end
    
    test "ssl requirements with user" do
      assert_ssl_required { get 'show', {:path => 'kontakt'}, with_user }
      assert_ssl_required { get 'stylesheet', {:path => 'layout.css'}, with_user }
    end
  end
end
