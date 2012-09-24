# -*- encoding : utf-8 -*-
require 'test_helper'

module SslRequirements
  class ArticlesControllerTest < ActionController::TestCase
    test_tested_files_checksum(
      ['app/controllers/articles_controller.rb', '8964002b761e81fc942dea3e4867161b'],
      ['config/routes.rb', 'a593e4312e018d6a068b0fb01d7ba989']
    )
    
    def setup
      @article = articles(:one)
      @subcategory = @article.subcategory
      @category = @subcategory.category
    end
    
    test "ssl requirements without user" do
      assert_ssl_denied { get 'index', @subcategory.url_hash }
      assert_ssl_denied { get 'edit_order', @subcategory.url_hash }
      assert_ssl_denied { post 'reorder', @subcategory.url_hash }
      assert_ssl_denied { get 'ask_destroy', @article.url_hash }
      assert_ssl_denied { get 'index' }
      assert_ssl_denied { get 'index', :format => 'js' }
      assert_ssl_denied { post 'create' }
      assert_ssl_denied { post 'create', :format => 'js' }
      assert_ssl_denied { get 'new' }
      assert_ssl_denied { get 'new', :format => 'js' }
      assert_ssl_denied { get 'edit', :id => @article.to_param }
      assert_ssl_denied { get 'edit', :id => @article.to_param, :format => 'js' }
      assert_ssl_denied { put 'update', :id => @article.to_param }
      assert_ssl_denied { put 'update', :id => @article.to_param, :format => 'js' }
      assert_ssl_denied { delete 'destroy', :id => @article.to_param }
      assert_ssl_denied { delete 'destroy', :id => @article.to_param, :format => 'js' }
    end
    
    test "ssl requirements with user" do
      assert_ssl_required { get 'index', @subcategory.url_hash, with_user }
      assert_ssl_required { get 'edit_order', @subcategory.url_hash, with_user }
      assert_ssl_required { post 'reorder', @subcategory.url_hash, with_user }
      assert_ssl_required { get 'ask_destroy', @article.url_hash, with_user }
      assert_ssl_required { get 'index', {}, with_user }
      assert_ssl_required { get 'index', {:format => 'js'}, with_user }
      assert_ssl_required { post 'create', {}, with_user }
      assert_ssl_required { post 'create', {:format => 'js'}, with_user }
      assert_ssl_required { get 'new', {}, with_user }
      assert_ssl_required { get 'new', {:format => 'js'}, with_user }
      assert_ssl_required { get 'edit', {:id => @article.to_param}, with_user }
      assert_ssl_required { get 'edit', {:id => @article.to_param, :format => 'js'}, with_user }
      assert_ssl_required { put 'update', {:id => @article.to_param} }
      assert_ssl_required { put 'update', {:id => @article.to_param, :format => 'js'}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @article.to_param}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @article.to_param, :format => 'js'}, with_user }
    end
  end
end
