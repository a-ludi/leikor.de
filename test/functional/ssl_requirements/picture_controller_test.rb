# -*- encoding : utf-8 -*-
require 'test_helper'

module SslRequirements
  class PictureControllerTest < ActionController::TestCase
    def setup
      @article = articles(:one)
      @article.picture = File::open(Rails.root.join('test/fixtures/pictures/jpg'))
      assert @article.save, 'picture assignment failed'
      
      @article_id = @article.to_param
    end
    
    test "ssl requirements without user" do
      assert_ssl_allowed { get 'pictures', :article_id => @article_id, :style => 'thumb',
          :extension => 'jpg' }
      refute_ssl_required { get 'pictures', :article_id => @article_id, :style => 'thumb',
          :extension => 'jpg' }
#      assert_ssl_allowed { get 'pictures', :article_id => @article_id }
#      refute_ssl_required { get 'pictures', :article_id => @article_id }
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
      assert_ssl_required { get 'pictures', {:article_id => @article_id, :style => 'thumb',
          :extension => 'jpg'}, with_user }
#      assert_ssl_required { get 'pictures', {:article_id => @article_id}, with_user }
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
