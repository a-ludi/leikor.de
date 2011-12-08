class RenamePictureFilenameInArticles < ActiveRecord::Migration
  def self.up
    rename_column :articles, :picture_filename, :picture_file_name
  end

  def self.down
    rename_column :articles, :picture_file_name, :picture_filename
  end
end
