require 'test_helper'

module SslRequirements
  class ProfilesControllerTest < ActionController::TestCase
    test_tested_files_checksum(
      ['app/controllers/profiles_controller.rb', '24e904ce217d4b53dacecfb4d93a8d07'],
      ['config/routes.rb', 'fc70545d8376feb442ad4df1ef94556f']
    )
    
    def setup
      @id = users(:john).to_param
    end
    
    test "ssl requirements without user" do
      assert_ssl_denied { get 'show_mine' }
      assert_ssl_denied { get 'edit_mine' }
      assert_ssl_denied { put 'update_mine' }
      assert_ssl_denied { get 'edit_password' }
      assert_ssl_denied { put 'update_password' }
      assert_ssl_denied { get 'index' }
      assert_ssl_denied { get 'index', :format => 'js' }
      assert_ssl_denied { post 'create' }
      assert_ssl_denied { post 'create', :format => 'js' }
      assert_ssl_denied { get 'edit', :id => @id }
      assert_ssl_denied { get 'edit', :id => @id, :format => 'js' }
      assert_ssl_denied { get 'show', :id => @id }
      assert_ssl_denied { get 'show', :id => @id, :format => 'js' }
      assert_ssl_denied { put 'update', :id => @id }
      assert_ssl_denied { put 'update', :id => @id, :format => 'js' }
      assert_ssl_denied { delete 'destroy', :id => @id }
      assert_ssl_denied { delete 'destroy', :id => @id, :format => 'js' }
      assert_ssl_denied { get 'new', :type => 'Customer' }
      assert_ssl_denied { get 'new', :type => 'Employee' }
    end
    
    test "ssl requirements with user" do
      assert_ssl_required { get 'show_mine', {}, with_user }
      assert_ssl_required { get 'edit_mine', {}, with_user }
      assert_ssl_required { put 'update_mine', {}, with_user }
      assert_ssl_required { get 'edit_password', {}, with_user }
      assert_ssl_required { put 'update_password', {}, with_user }
      assert_ssl_required { get 'index', {}, with_user }
      assert_ssl_required { get 'index', {:format => 'js'}, with_user }
      assert_ssl_required { post 'create', {}, with_user }
      assert_ssl_required { post 'create', {:format => 'js'}, with_user }
      assert_ssl_required { get 'edit', {:id => @id}, with_user }
      assert_ssl_required { get 'edit', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { get 'show', {:id => @id}, with_user }
      assert_ssl_required { get 'show', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { put 'update', {:id => @id}, with_user }
      assert_ssl_required { put 'update', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @id}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @id, :format => 'js'}, with_user }
      assert_ssl_required { get 'new', {:type => 'Customer'}, with_user }
      assert_ssl_required { get 'new', {:type => 'Employee'}, with_user }
    end
  end
end
