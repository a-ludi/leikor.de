class DropPictures < ActiveRecord::Migration
  def self.up
    drop_table :pictures
  end
end
