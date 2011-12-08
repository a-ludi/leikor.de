# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :password
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end