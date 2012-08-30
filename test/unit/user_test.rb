# -*- encoding : utf-8 -*-
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test_tested_files_checksum 'd52037449f65c02148f37cc35e2c2f90'

  test "notes should be marked up with maruku" do
    assert_equal users(:moritz).notes,
        "<p>Moritz bleibt <strong>immer</strong> treu.</p>"
  end
  
  test "has a reset_password_request" do
    assert_equal users(:john).reset_password_request,
        secure_user_requests(:john_reset)
  end
  
  test "deletes reset_password_request on destroy" do
    users(:john).destroy
    
    assert_raises ActiveRecord::RecordNotFound do
      secure_user_requests(:john_reset)
    end
  end
  
  test "has a confirm_registration_request" do
    assert_equal users(:maxi).confirm_registration_request,
        secure_user_requests(:max_confirm)
  end
  
  test "deletes confirm_registration_request on destroy" do
    users(:maxi).destroy
    
    assert_raises ActiveRecord::RecordNotFound do
      secure_user_requests(:max_confirm)
    end
  end
  
  test "has many owned_blog_posts" do
    assert_equal users(:maxi).owned_blog_posts,
        blog_posts(:mailed_post, :public_post)
  end
  
  test "has many edited_blog_posts" do
    assert_equal users(:john).edited_blog_posts, [blog_posts(:public_post)]
  end
  
  test "should have a name" do
    users(:john).name = ''
    assert_errors_on users(:john), :on => :name
  end

  test "should have a login" do
    users(:john).login = ''
    assert_errors_on users(:john), :on => :login
  end

  test "should have a type" do
    users(:john).type = nil
    assert_errors_on users(:john), :on => :type
  end

  test "should have a primary_email_address" do
    users(:john).primary_email_address = ''
    assert_errors_on users(:john), :on => :primary_email_address
  end

  test "should have a password" do
    users(:john).password = ''
    assert_errors_on users(:john), :on => :password
  end

  test "should have correctly formatted primary_email_address" do
    %w(john@john john@users. @users.com john@.com).each do |invalid_address|
      users(:john).primary_email_address = invalid_address
      assert_errors_on users(:john), :on => :primary_email_address,
          :message => "accepted invalid email address <#{invalid_address}>"
    end
  end
  
  test "should have a long enough login" do
    users(:john).login = 'jon'
    assert_errors_on users(:john), :on => :login
  end
  
  test "should have a short enough login" do
    users(:john).login = 'john_doe_the_hero_of_america_damn'
    assert_errors_on users(:john), :on => :login
  end
  
  test "should have a valid first char in login" do
    users(:john).login = '_john'
    assert_errors_on users(:john), :on => :login
  end
  
  test "should have only valid chars in login" do
    users(:john).login = 'john!'
    assert_errors_on users(:john), :on => :login
    
    users(:john).login = 'jo\n'
    assert_errors_on users(:john), :on => :login
    
    users(:john).login = 'john&brother'
    assert_errors_on users(:john), :on => :login
    
    users(:john).login = 'jöhne'
    assert_errors_on users(:john), :on => :login
  end
  
  test "should have a unique login" do
    users(:john).login = users(:maxi).login
    assert_errors_on users(:john), :on => :login
  end
  
  test "should have a long password" do
    users(:john).password = 'big'
    assert_errors_on users(:john), :on => :password
  end
  
  test "raises error with invalid password hash" do
    users(:john)[:password] = 'not a valid hash'
    assert_raises BCrypt::Errors::InvalidHash do
      users(:john).save
    end
  end
  
  test "password is not stored as clear text" do
    assert users(:john)[:password] != 'sekret'
  end
  
  test "password matches correct password" do
    assert users(:john).password == 'sekret'
  end
  
  test "password matches after setting new" do
    users(:john).password = 'sekuriti'
    assert_equal users(:john).password, 'sekuriti'
  end
  
  test "should set a random password" do
    users(:john).set_random_password
    
    refute users(:john).password == 'sekret'
    
    old_password = users(:john).password.to_s
    users(:john).set_random_password
    
    refute users(:john).password.to_s == old_password
  end
  
  test "registration should be confirmed" do
    assert users(:john).registration?(:confirmed)
  end
  
  test "registration should be unconfirmed" do
    refute users(:maxi).registration?(:confirmed)
  end
  
  test "registration should be denied" do
    users(:maxi).registration = :denied
    
    assert users(:maxi).registration?(:denied)
  end
  
  test "registration should be undenied" do
    refute users(:john).registration?(:denied)
    refute users(:maxi).registration?(:denied)
  end
  
  test "should not deny already confirmed registration" do
    assert_raises RuntimeError do
      users(:john).registration = :denied
    end
  end
  
  test "email_address_with_name returns correct value" do
    assert_equal users(:john).email_address_with_name,
        %Q("John Doe" <john@doe.com>)
  end
  
  test "email_address_with_name should return primary by default" do
    assert_equal users(:john).email_address_with_name,
        users(:john).email_address_with_name(:primary)
  end
end
