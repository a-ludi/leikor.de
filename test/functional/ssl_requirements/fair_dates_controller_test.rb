# -*- encdoing : utf-8 -*-
require 'test_helper'

module SslRequirements
  class FairDatesControllerTest < ActionController::TestCase
    def setup
      @id = fair_dates(:one).to_param
    end

    test "ssl requirements without user" do
      assert_ssl_denied { get 'index' }
      assert_ssl_denied { post 'create' }
      assert_ssl_denied { get 'new' }
      assert_ssl_denied { get 'edit', :id => @id }
      assert_ssl_denied { get 'show', :id => @id }
      assert_ssl_denied { put 'update', :id => @id }
      assert_ssl_denied { delete 'destroy', :id => @id }
    end

    test "ssl requirements with user" do
      assert_ssl_required { get 'index', {}, with_user }
      assert_ssl_required { post 'create', {}, with_user }
      assert_ssl_required { get 'new', {}, with_user }
      assert_ssl_required { get 'edit', {:id => @id}, with_user }
      assert_ssl_required { get 'show', {:id => @id}, with_user }
      assert_ssl_required { put 'update', {:id => @id}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @id}, with_user }
    end
  end
end
