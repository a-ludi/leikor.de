# -*- encoding : utf-8 -*-

ActionMailer::Base.smtp_settings = {
    :address => ENV['SENDGRID_ADDRESS'],
    :port => ENV['SENDGRID_PORT'],
    :authentication => :plain,
    :domain => ENV['SENDGRID_DOMAIN'],
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :enable_starttls_auto => true }
