class AddUniqueIndicesToArticleHabtmTables < ActiveRecord::Migration
  def self.up
    add_index :articles_colors, [:article_id, :color_id], :unique => true
    add_index :articles_materials, [:article_id, :material_id], :unique => true
  end

  def self.down
    remove_index :articles_colors, [:article_id, :color_id]
    remove_index :articles_materials, [:article_id, :material_id]
  end
end
