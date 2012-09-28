class CreatePrices < ActiveRecord::Migration
  def self.up
    create_table :prices do |t|
      t.decimal :amount
      t.integer :minimum_count, :precision => 12, :scale => 4
      t.belongs_to :article

      t.timestamps
    end
  end

  def self.down
    drop_table :prices
  end
end
