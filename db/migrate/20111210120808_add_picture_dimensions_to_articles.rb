class AddPictureDimensionsToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :picture_width, :integer
    add_column :articles, :picture_height, :integer
  end

  def self.down
    remove_column :articles, :picture_width
    remove_column :articles, :picture_height
  end
end
