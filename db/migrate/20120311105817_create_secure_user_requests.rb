class CreateSecureUserRequests < ActiveRecord::Migration
  def self.up
    create_table :secure_user_requests do |t|
      t.string :external_id
      t.string :action
      t.text :memo
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :secure_user_requests
  end
end
