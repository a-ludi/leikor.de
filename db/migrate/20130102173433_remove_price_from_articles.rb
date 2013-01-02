class RemovePriceFromArticles < ActiveRecord::Migration
  def self.up
    remove_column :articles, :price
  end

  def self.down
    add_column :articles, :price, :float
  end
end
