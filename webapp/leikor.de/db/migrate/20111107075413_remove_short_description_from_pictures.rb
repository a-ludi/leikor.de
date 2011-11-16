class RemoveShortDescriptionFromPictures < ActiveRecord::Migration
  def self.up
    remove_column :pictures, :short_description
  end

  def self.down
    add_column :pictures, :short_description, :string
  end
end
