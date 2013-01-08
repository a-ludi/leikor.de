# -*- encoding : utf-8 -*-

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.googlemail.com',
    :port => 587,
    :authentication => :plain,
    :domain => ENV['GMAIL_SMTP_DOMAIN'],
    :user_name => ENV['GMAIL_SMTP_USER'],
    :password => ENV['GMAIL_SMTP_PASSWORD'],
    :enable_starttls_auto => true }