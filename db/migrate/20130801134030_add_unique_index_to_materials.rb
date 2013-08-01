class AddUniqueIndexToMaterials < ActiveRecord::Migration
  def self.up
    add_index :materials, [:name], :unique => true
  end

  def self.down
    remove_index :materials, [:name]
  end
end
