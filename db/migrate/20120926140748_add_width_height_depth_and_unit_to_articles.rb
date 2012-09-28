class AddWidthHeightDepthAndUnitToArticles < ActiveRecord::Migration
  def self.up
    change_table :articles do |t|
      t.column :width, :float, :null => true
      t.column :height, :float, :null => true
      t.column :depth, :float, :null => true
      t.column :unit, :string, :limit => 5, :null => true
    end
  end

  def self.down
    change_table :articles do |t|
      t.remove :width, :height, :depth, :unit
    end
  end
end
