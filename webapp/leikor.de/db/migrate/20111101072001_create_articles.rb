class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :article_number
      t.string :name
      t.text :description
      t.float :price
      t.integer :category_id

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
