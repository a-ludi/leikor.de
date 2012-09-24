# -*- encoding : utf-8 -*-
require 'test_helper'

module SslRequirements
  class PictureControllerTest < ActionController::TestCase
    test_tested_files_checksum(
      ['app/controllers/picture_controller.rb', 'ab3ef36a4880bcf4a40fa3e224692088'],
      ['config/routes.rb', 'b3b7d3a8d5580deca782cc3f9ba9acca']
    )
    
    def setup
      @article_id = articles(:one).to_param
    end
    
    test "ssl requirements without user" do
      assert_ssl_denied { get 'pictures', :article_id => @article_id, :style => 'small',
          :extension => 'jpg' }
      assert_ssl_denied { get 'pictures', :article_id => @article_id }
      assert_ssl_denied { get 'new', :article_id => @article_id }
      assert_ssl_denied { get 'new', :article_id => @article_id, :format => 'png' }
      assert_ssl_denied { get 'edit', :article_id => @article_id }
      assert_ssl_denied { get 'edit', :article_id => @article_id, :format => 'png' }
      assert_ssl_denied { get 'show', :article_id => @article_id }
      assert_ssl_denied { get 'show', :article_id => @article_id, :format => 'png' }
      assert_ssl_denied { put 'update', :article_id => @article_id }
      assert_ssl_denied { put 'update', :article_id => @article_id, :format => 'png' }
      assert_ssl_denied { delete 'destroy', :article_id => @article_id }
      assert_ssl_denied { delete 'destroy', :article_id => @article_id, :format => 'png' }
      assert_ssl_denied { post 'create', :article_id => @article_id }
      assert_ssl_denied { post 'create', :article_id => @article_id, :format => 'png' }
    end
    
    test "ssl requirements with user" do
      assert_ssl_required { get 'pictures', {:article_id => @article_id, :style => 'small',
          :extension => 'jpg'}, with_user }
      assert_ssl_required { get 'pictures', {:article_id => @article_id}, with_user }
      assert_ssl_required { get 'new', {:article_id => @article_id}, with_user }
      assert_ssl_required { get 'new', {:article_id => @article_id, :format => 'png'}, with_user }
      assert_ssl_required { get 'edit', {:article_id => @article_id}, with_user }
      assert_ssl_required { get 'edit', {:article_id => @article_id, :format => 'png'}, with_user }
      assert_ssl_required { get 'show', {:article_id => @article_id}, with_user }
      assert_ssl_required { get 'show', {:article_id => @article_id, :format => 'png'}, with_user }
      assert_ssl_required { put 'update', {:article_id => @article_id}, with_user }
      assert_ssl_required { put 'update', {:article_id => @article_id, :format => 'png'}, with_user }
      assert_ssl_required { delete 'destroy', {:article_id => @article_id}, with_user }
      assert_ssl_required { delete 'destroy', {:article_id => @article_id, :format => 'png'}, with_user }
      assert_ssl_required { post 'create', {:article_id => @article_id}, with_user }
      assert_ssl_required { post 'create', {:article_id => @article_id, :format => 'png'}, with_user }
    end
  end
end
