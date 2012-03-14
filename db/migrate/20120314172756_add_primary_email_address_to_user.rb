class AddPrimaryEmailAddressToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :primary_email_address, :string
  end

  def self.down
    remove_column :users, :primary_email_address
  end
end
