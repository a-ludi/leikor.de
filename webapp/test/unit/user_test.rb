require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "save succeeds with test hash" do
    assert_creates_record_from User, {:name => 'Heinz Hinze', :login => 'hinze', :password => 'loeffel'}
  end
  
  test "record invalid without name" do
    users(:john).name = ''
    assert_errors_on users(:john), :on => :name
  end

  test "record invalid without login" do
    users(:john).login = ''
    assert_errors_on users(:john), :on => :login
  end

  test "record invalid without password" do
    users(:john).password = ''
    assert_errors_on users(:john), :on => :password
  end

  test "record invalid with short login" do
    users(:john).login = 'jon'
    assert_errors_on users(:john), :on => :login
  end
  
  test "record invalid with long login" do
    users(:john).login = 'john_doe_the_hero_of_america_damn'
    assert_errors_on users(:john), :on => :login
  end
  
  test "record invalid with invalid first char in login" do
    users(:john).login = '_john'
    assert_errors_on users(:john), :on => :login
  end
  
  test "record invalid with invalid char in login" do
    users(:john).login = 'john!'
    assert_errors_on users(:john), :on => :login
    
    users(:john).login = 'jo\n'
    assert_errors_on users(:john), :on => :login
    
    users(:john).login = 'john&brother'
    assert_errors_on users(:john), :on => :login
    
    users(:john).login = 'jöhne'
    assert_errors_on users(:john), :on => :login
  end
  
  test "record invalid with non-unique login" do
    users(:john).login = users(:max).login
    assert_errors_on users(:john), :on => :login
  end
  
  test "record invalid with short password" do
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
  
  test "saves correct password length" do
    users(:john).send(:save_password_length, 'sekuriti')
    assert_equal users(:john).send(:password_length), 8
  end
  
  test "saves password length on set" do
    users(:john).password = 'sekuriti'
    assert_equal users(:john).send(:password_length), 8
  end
end
