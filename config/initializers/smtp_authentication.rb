# -*- encoding : utf-8 -*-

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.googlemail.com',
    :port => 587,
    :authentication => :plain,
    :domain => 'ludis-laptop',
    :user_name => 'benachrichtigung@leikor.de',
    :password => 'DnUz4ANu3jO6oydBeV73ev/E9uY39p7dGqRuN3inwiI',
    :enable_starttls_auto => true }

