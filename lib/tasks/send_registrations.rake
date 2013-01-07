# -*- encoding : utf-8 -*-

namespace :app do
  namespace :users do
    desc 'Send registration mails to all unconfirmed users not having denied registration. No mail will be sent if the present confirm registration request is older than OLDER_THAN, e.g. `OLDER_THAN=5.days`.'
    task :send_registrations => [:environment] do |t, args|
      fetch_older_than!
      sent_mails_count = 0
      users_with_errors = []
      User.all.each do |user|
        begin
          next if user.registration? :confirmed or
                  user.registration? :denied or
                  user.confirm_registration_request.updated_at.in(@older_than).future?
          
          user.confirm_registration_request.touch
          Notifier.deliver_confirm_registration_request user
          sent_mails_count += 1
        rescue => error
          users_with_errors << user
          $stderr.puts "#{error.class}: #{error.to_s}"
          $stderr.puts error.backtrace
        end
      end
      
      puts "sent mails/users: #{sent_mails_count}/#{User.count}"
      unless users_with_errors.empty?
        puts "errors occured while processing the following users:"
        puts users_with_errors.map{|u| u.login}.join(", ")
      end
    end
  end
end

private

def fetch_older_than!
  @older_than = eval(ENV['OLDER_THAN'] || '') || 0
  
  unless @older_than.is_a? Integer and @older_than >= 0
    raise ArgumentError, 'OLDER_THAN must be an expression, which evaluates to a
        positive integer or zero'.squish
  end
end
