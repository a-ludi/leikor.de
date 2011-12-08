class CreateFairDates < ActiveRecord::Migration
  def self.up
    create_table :fair_dates do |t|
      t.date :from
      t.date :to
      t.string :name
      t.string :homepage
      t.string :stand
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :fair_dates
  end
end
