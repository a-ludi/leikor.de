class CreateArticlesMaterials < ActiveRecord::Migration
  def self.up
    create_table :articles_materials, :id => false do |t|
      t.references :article, :material
      t.index [:article_id, :material_id], :unique => true
    end
  end

  def self.down
    drop_table :articles_materials
  end
end
