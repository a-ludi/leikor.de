# -*- encoding: utf-8 -*-
require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  tests_mailer Notifier
  
  test "reset password request" do
    @user = users(:john)
    mailer.deliver_reset_password_request(@user)
    
    assert_mail_sent
    assert_mailed_to @user.primary_email_address
    assert_mail_reply_to Notifier::LEIKOR_MAIL_ADDRESSES[:technical]
    assert_mail_body_match Regexp.new(@user.reset_password_request.external_id)
  end
  
  test "confirm registration request" do
    @user = users(:maxi)
    
    Notifier.deliver_confirm_registration_request(@user)
    
    assert_mail_sent
    assert_mailed_to @user.primary_email_address
    assert_mail_reply_to Notifier::LEIKOR_MAIL_ADDRESSES[:technical]
    assert_mail_body_match Regexp.new(@user.confirm_registration_request.external_id)
  end
  
  test "blog post" do
    @user = users(:maxi)
    blog_post = blog_posts(:mailed_post)
    
    Notifier.deliver_blog_post(@user, blog_post)
    
    assert_mail_sent
    assert_mailed_to @user.primary_email_address
    assert_mail_reply_to Notifier::LEIKOR_MAIL_ADDRESSES[:customer]
  end
end
