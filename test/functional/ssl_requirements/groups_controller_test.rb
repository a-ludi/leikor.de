require 'test_helper'

module SslRequirements
  class GroupsControllerTest < ActionController::TestCase
    def setup
      @profile_id = users(:john).login
      @id = 'Holz'
    end
    
    test "ssl requirements without user" do
      assert_ssl_denied { post 'create', :profile_id => @profile_id }
      assert_ssl_denied { put 'update', :profile_id => @profile_id, :id => @id }
      assert_ssl_denied { delete 'destroy', :profile_id => @profile_id, :id => @id }
      assert_ssl_denied { get 'suggest' }
    end
    
    test "ssl requirements with user" do
      assert_ssl_required { post 'create', {:profile_id => @profile_id}, with_user }
      assert_ssl_required { put 'update', {:profile_id => @profile_id, :id => @id}, with_user }
      assert_ssl_required { delete 'destroy', {:profile_id => @profile_id, :id => @id}, with_user }
      assert_ssl_required { get 'suggest', {}, with_user }
    end
  end
end
