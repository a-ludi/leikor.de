class CreateArticlesColors < ActiveRecord::Migration
  def self.up
    create_table :articles_colors, :id => false do |t|
      t.references :article, :color
      t.index [:article_id, :color_id], :unique => true
    end
  end

  def self.down
    drop_table :articles_colors
  end
end
