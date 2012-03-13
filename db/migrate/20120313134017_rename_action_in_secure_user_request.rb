class RenameActionInSecureUserRequest < ActiveRecord::Migration
  def self.up
    rename_column :secure_user_request, :action, :type
  end

  def self.down
    rename_column :secure_user_request, :type, :action
  end
end
