# -*- encoding : utf-8 -*-

ActionMailer::Base.smtp_settings = {
    :address => ENV['GMAIL_SMTP_ADDRESS'],
    :port => ENV['GMAIL_SMTP_PORT'],
    :authentication => :plain,
    :domain => ENV['GMAIL_SMTP_DOMAIN'],
    :user_name => ENV['GMAIL_SMTP_USER'],
    :password => ENV['GMAIL_SMTP_PASSWORD'],
    :enable_starttls_auto => true }
