require 'test_helper'

module SslRequirements
  class GroupsControllerTest < ActionController::TestCase
    test_tested_files_checksum(
      ['app/controllers/groups_controller.rb', '452e1667dbe0443a4aa6c76094439a92'],
      ['config/routes.rb', 'a593e4312e018d6a068b0fb01d7ba989']
    )

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
