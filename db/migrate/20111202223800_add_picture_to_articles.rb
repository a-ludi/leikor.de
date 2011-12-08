# -*- encoding : utf-8 -*-
class AddPictureToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :picture_filename, :string
    add_column :articles, :picture_content_type, :string
    add_column :articles, :picture_file, :binary
    add_column :articles, :picture_thumb_file, :binary
    add_column :articles, :picture_medium_file, :binary
    add_column :articles, :picture_large_file, :binary
  end

  def self.down
    remove_column :articles, :picture_file
    remove_column :articles, :picture_thumb_file
    remove_column :articles, :picture_medium_file
    remove_column :articles, :picture_large_file
  end
end
