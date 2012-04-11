# -*- encoding: utf-8 -*-

class Notifier < ActionMailer::Base
  include ActionController::Layout
  include ActionController::Translation
  
  layout 'layouts/mail.text'
  
  DEFAULT_SENDER = "notifier@leikor.de"
  TECHNICAL_SUPPORT = "webmaster@leikor.de"
  CUSTOMER_SUPPORT = "info@leikor.de"
  
  def reset_password_request(recipient)
    recipients recipient.email_address_with_name
    from       Notifier::DEFAULT_SENDER
    reply_to   Notifier::TECHNICAL_SUPPORT
    subject    t('activerecord.models.secure_user_request/reset_password')
    body       :user => recipient,
               :request => recipient.reset_password_request
  end
  
  def confirm_registration_request(recipient)
    recipients recipient.email_address_with_name
    from       Notifier::DEFAULT_SENDER
    reply_to   Notifier::TECHNICAL_SUPPORT
    subject    t('activerecord.models.secure_user_request/confirm_registration')
    body       :user => recipient,
               :request => recipient.confirm_registration_request
  end
  
  def blog_post(recipient, blog_post)
    recipients recipient.email_address_with_name
    from       Notifier::DEFAULT_SENDER
    reply_to   Notifier::CUSTOMER_SUPPORT
    subject    t('views.notifier.blog_post.title', :title => blog_post.title)
    body       :user => recipient,
               :blog_post => blog_post
  end
end
