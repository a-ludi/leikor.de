require 'test_helper'

module SslRequirements
  class BlogControllerTest < ActionController::TestCase
    test_tested_files_checksum(
      ['app/controllers/blog_controller.rb', 'aedf0b479e76defc2628bb74f72f5197'],
      ['config/routes.rb', 'a593e4312e018d6a068b0fb01d7ba989']
    )
      
    def setup
      @id = blog_posts(:mailed_post).to_param
    end
    
    test "ssl requirements without user" do
      assert_ssl_denied { get 'readers' }
      assert_ssl_denied { get 'readers', :format => 'js' }
      assert_ssl_denied { get 'index' }
      assert_ssl_denied { get 'index', :format => 'js' }
      assert_ssl_denied { post 'create' }
      assert_ssl_denied { post 'create', :format => 'js' }
      assert_ssl_denied { get 'new' }
      assert_ssl_denied { get 'new', :format => 'js' }
      assert_ssl_denied { post 'mail', :id => @id }
      assert_ssl_denied { post 'mail', :id => @id, :format => 'js' }
      assert_ssl_denied { get 'mail', :id => @id }
      assert_ssl_denied { get 'mail', :id => @id, :format => 'js' }
      assert_ssl_denied { post 'publish', :id => @id }
      assert_ssl_denied { post 'publish', :id => @id, :format => 'js' }
      assert_ssl_denied { get 'publish', :id => @id }
      assert_ssl_denied { get 'publish', :id => @id, :format => 'js' }
      assert_ssl_denied { get 'edit', :id => @id }
      assert_ssl_denied { get 'edit', :id => @id, :format => 'js' }
      assert_ssl_denied { put 'update', :id => @id }
      assert_ssl_denied { put 'update', :id => @id, :format => 'js' }
      assert_ssl_denied { delete 'destroy', :id => @id }
      assert_ssl_denied { delete 'destroy', :id => @id, :format => 'js' }
    end
    
    test "ssl requirements with user" do
      assert_ssl_required { get 'readers', {}, with_user }
      assert_ssl_required { get 'readers', {:format => 'js'}, with_user }
      assert_ssl_required { get 'index', {}, with_user }
      assert_ssl_required { get 'index', {:format => 'js'}, with_user }
      assert_ssl_required { post 'create', {}, with_user }
      assert_ssl_required { post 'create', {:format => 'js'}, with_user }
      assert_ssl_required { get 'new', {}, with_user }
      assert_ssl_required { get 'new', {:format => 'js'}, with_user }
      assert_ssl_required { post 'mail', {:id => @id}, with_user }
      assert_ssl_required { post 'mail', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { get 'mail', {:id => @id}, with_user }
      assert_ssl_required { get 'mail', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { post 'publish', {:id => @id}, with_user }
      assert_ssl_required { post 'publish', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { get 'publish', {:id => @id}, with_user }
      assert_ssl_required { get 'publish', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { get 'edit', {:id => @id}, with_user }
      assert_ssl_required { get 'edit', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { put 'update', {:id => @id}, with_user }
      assert_ssl_required { put 'update', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @id}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @id, :format => 'js'}, with_user }
    end
  end
end
