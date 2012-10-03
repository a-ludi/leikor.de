class RenameColumnPictureFilenameToPictureFileNameInMaterials < ActiveRecord::Migration
  def self.up
    rename_column :materials, :picture_filename, :picture_file_name
  end

  def self.down
    rename_column :materials, :picture_file_name, :picture_filename
  end
end
