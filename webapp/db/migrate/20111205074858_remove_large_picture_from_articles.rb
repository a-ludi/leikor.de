class RemoveLargePictureFromArticles < ActiveRecord::Migration
  def self.up
    remove_column :articles, :picture_large_file
  end

  def self.down
    add_column :articles, :picture_large_file, :binary
  end
end
