# -*- encoding: utf-8 -*-
require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  tests Notifier
  test_tested_files_checksum '966f564ee91903df8ecc29a2abc51019'
  
  test "reset password request" do
    user = users(:john)
    
    email = Notifier.deliver_reset_password_request(user)
    refute_empty ActionMailer::Base.deliveries
    
    assert_equal [user.primary_email_address], email.to
    assert_equal [Notifier::LEIKOR_MAIL_ADDRESSES[:technical]], email.reply_to
    assert_match Regexp.new(user.reset_password_request.external_id), email.body
  end
  
  test "confirm registration request" do
    user = users(:max)
    
    email = Notifier.deliver_confirm_registration_request(user)
    refute_empty ActionMailer::Base.deliveries
    
    assert_equal [user.primary_email_address], email.to
    assert_equal [Notifier::LEIKOR_MAIL_ADDRESSES[:technical]],
        email.reply_to
    assert_match Regexp.new(user.confirm_registration_request.external_id),
        email.body
  end
  
  test "blog post" do
    user = users(:max)
    blog_post = blog_posts(:mailed_post)
    
    email = Notifier.deliver_blog_post(user, blog_post)
    refute_empty ActionMailer::Base.deliveries
    
    assert_equal [user.primary_email_address], email.to
    assert_equal [Notifier::LEIKOR_MAIL_ADDRESSES[:customer]], email.reply_to
  end
end
