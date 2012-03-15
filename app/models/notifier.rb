class Notifier < ActionMailer::Base
  include ActionController::Layout
  include ActionController::Translation
  
  layout 'layouts/mail.text'
  
  DEFAULT_SENDER = "notifier@leikor.de"
  DEFAULT_REPLY_TO = "webmaster@leikor.de"
  
  def reset_password_request(recipient)
    recipients recipient.email_address_with_name
    from       Notifier::DEFAULT_SENDER
    reply_to   Notifier::DEFAULT_REPLY_TO
    subject    t('activerecord.models.secure_user_request/reset_password')
    body       :user => recipient,
               :request => recipient.reset_password_request
  end
  
  def confirm_registration_request(recipient)
    recipients recipient.email_address_with_name
    from       Notifier::DEFAULT_SENDER
    reply_to   Notifier::DEFAULT_REPLY_TO
    subject    t('activerecord.models.secure_user_request/confirm_registration')
    body       :user => recipient,
               :request => recipient.confirm_registration_request
  end
end
