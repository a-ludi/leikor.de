desc "This tasks are called by the Heroku scheduler add-on"
namespace :scheduler do
  desc "Runs all daily jobs"
  task :daily => %w(scheduler:daily:clean_up_secure_user_requests)
  
  namespace :daily do
    desc "Removes expired secure user requests"
    task :clean_up_secure_user_requests => :environment do
      print "Removing expired reset password requests ... "
      SecureUserRequest::ResetPassword.all.each { |request| request.delete if request.expired? }
      puts "done."
    end
  end
end
