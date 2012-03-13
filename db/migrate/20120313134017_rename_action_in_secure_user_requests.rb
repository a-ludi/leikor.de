class RenameActionInSecureUserRequests < ActiveRecord::Migration
  def self.up
    SecureUserRequest.delete_all
    rename_column :secure_user_requests, :action, :type
  end

  def self.down
    rename_column :secure_user_requests, :type, :action
  end
end
