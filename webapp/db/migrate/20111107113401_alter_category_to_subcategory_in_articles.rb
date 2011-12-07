# -*- encoding : utf-8 -*-
class AlterCategoryToSubcategoryInArticles < ActiveRecord::Migration
  def self.up
    rename_column :articles, :category_id, :subcategory_id
  end

  def self.down
    rename_column :articles, :subcategory_id, :category_id
  end
end
