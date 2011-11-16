require 'test_helper'

class UserTest < ActiveSupport::TestCase
  TEST_USER_HASH = {:name => 'Heinz Hinze', :login => 'hinze', :password => 'loeffel'}

  test "save succeeds with TEST_USER_HASH" do
    assert_creates_record_from User, TEST_USER_HASH
  end
  
  test "record invalid without name" do
    user = User.create TEST_USER_HASH.merge(:name => '')
    assert_errors_on user, :on => :name
  end

  test "record invalid without login" do
    user = User.create TEST_USER_HASH.merge(:login => '')
    assert_errors_on user, :on => :login
  end

  test "record invalid without password" do
    user = User.create TEST_USER_HASH.merge(:password => '')
    assert_errors_on user, :on => :password
  end

  test "record invalid with short login" do
    user = User.create TEST_USER_HASH.merge(:login => 'heh')
    assert_errors_on user, :on => :login
  end
  
  test "record invalid with long login" do
    user = User.create TEST_USER_HASH.merge(:login => 'john_doe_the_hero_of_america_damn')
    assert_errors_on user, :on => :login
  end
  
  test "record invalid with invalid first char in login" do
    user = User.create TEST_USER_HASH.merge(:login => '_heinz')
    assert_errors_on user, :on => :login
  end
  
  test "record invalid with invalid char in login" do
    user = User.create TEST_USER_HASH.merge(:login => 'hinze!')
    assert_errors_on user, :on => :login
    
    user = User.create TEST_USER_HASH.merge(:login => 'h/nze')
    assert_errors_on user, :on => :login
    
    user = User.create TEST_USER_HASH.merge(:login => 'hinze&co')
    assert_errors_on user, :on => :login
    
    user = User.create TEST_USER_HASH.merge(:login => 'hinze-und-söhne')
    assert_errors_on user, :on => :login
  end
  
  test "record invalid with non-unique login" do
    user = User.create TEST_USER_HASH.merge(:login => users(:john).login)
    assert_errors_on user, :on => :login
  end
  
  test "record invalid with short password" do
    user = User.create TEST_USER_HASH.merge(:password => 'tuer')
    assert_errors_on user, :on => :password
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
  
  test "saves correct password length" do
    users(:john).send(:save_password_length, 'sekuriti')
    assert_equal users(:john).send(:password_length), 8
  end
  
  test "saves password length on set" do
    users(:john).password = 'sekuriti'
    assert_equal users(:john).send(:password_length), 8
  end
end
