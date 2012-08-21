# -*- encoding : utf-8 -*-

module SmtpAuthentication
  def self.setup
    ActionMailer::Base.smtp_settings = {
        :address => 'smtp.googlemail.com',
        :port => 587,
        :authentication => :plain,
        :domain => 'ludis-laptop',
        :user_name => 'arne@leikor.de',
        :password => 'J17/i$8?',
        :enable_starttls_auto => true }
  end
end

