# -*- encoding : utf-8 -*-
require 'test_helper'

module SslRequirements
  class CategoriesControllerTest < ActionController::TestCase
    test_tested_files_checksum(
      ['app/controllers/categories_controller.rb', 'fe5334fbfda3223856f903b6f353b02d'],
      ['config/routes.rb', 'b3b7d3a8d5580deca782cc3f9ba9acca']
    )
    
    def setup
      @id = @subcategory = categories(:sub1).to_param
      @category = categories(:sub1).category.to_param
    end

    test "ssl requirements without user" do
      assert_ssl_denied { get 'index' }
      assert_ssl_denied { get 'subindex', :category => @category }
      assert_ssl_denied { get 'ask_destroy', :category => @category }
      assert_ssl_denied { get 'ask_destroy', :category => @category, :subcategory => @subcategory }
      assert_ssl_denied { post 'create' }
      assert_ssl_denied { get 'new' }
      assert_ssl_denied { get 'edit', :id => @id }
      assert_ssl_denied { put 'update', :id => @id }
      assert_ssl_denied { delete 'destroy', :id => @id }
      assert_ssl_denied { post 'reorder' }
    end

    test "ssl requirements with user" do
      assert_ssl_required { get 'index', {}, with_user }
      assert_ssl_required { get 'subindex', {:category => @category}, with_user }
      assert_ssl_required { get 'ask_destroy', {:category => @category}, with_user }
      assert_ssl_required { get 'ask_destroy', {:category => @category, :subcategory => @subcategory},
          with_user }
      assert_ssl_required { post 'create', {}, with_user }
      assert_ssl_required { get 'new', {}, with_user }
      assert_ssl_required { get 'edit', {:id => @id}, with_user }
      assert_ssl_required { put 'update', {:id => @id}, with_user }
      assert_ssl_required { delete 'destroy', {:id => @id}, with_user }
      assert_ssl_required { post 'reorder', {}, with_user }
    end
  end
end
