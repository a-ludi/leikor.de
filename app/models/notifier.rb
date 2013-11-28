# -*- encoding: utf-8 -*-

class Notifier < ActionMailer::Base
  include ActionController::Layout
  include ActionController::Translation
  
  layout 'layouts/mail.text'
  
  LEIKOR_MAIL_ADDRESSES = {
    :default => 'benachrichtigung@leikor.de',
    :technical => 'webmaster@leikor.de',
    :customer => 'info@leikor.de'
  }
  
  def reset_password_request(recipient)
    recipients recipient.email_address_with_name
    from       leikor_mail_address
    reply_to   leikor_mail_address(:technical)
    subject    t('activerecord.models.secure_user_request/reset_password')
    body       :user => recipient, :request => recipient.reset_password_request
  end
  
  def confirm_registration_request(recipient)
    recipients recipient.email_address_with_name
    from       leikor_mail_address
    reply_to   leikor_mail_address(:technical)
    subject    t('activerecord.models.secure_user_request/confirm_registration')
    body       :user => recipient, :request => recipient.confirm_registration_request
  end
  
  def blog_post(recipient_id, blog_post_id)
    recipient = User.find recipient_id
    blog_post = BlogPost.find blog_post_id
    
    recipients recipient.email_address_with_name
    from       leikor_mail_address
    reply_to   leikor_mail_address(:customer)
    subject    t('views.notifier.blog_post.title', :title => blog_post.title)
    body       :user => recipient, :blog_post => blog_post
  end

protected
  
  def leikor_mail_address(type=:default)
    return "LEIKOR <#{Notifier::LEIKOR_MAIL_ADDRESSES[type]}>"
  end
end
