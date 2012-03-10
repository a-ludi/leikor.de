class AddTypeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :type, :string
    User.reset_column_information
    User.all.each do |user|
      user.type = 'Employee'
    end
  end

  def self.down
    remove_column :users, :type
  end
end
