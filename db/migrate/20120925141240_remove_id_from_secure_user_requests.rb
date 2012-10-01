class RemoveIdFromSecureUserRequests < ActiveRecord::Migration
  def self.up
    remove_column :secure_user_requests, :id
  end

  def self.down
    add_column :secure_user_requests, :id, :integer
  end
end
