class RenameFromAndToColumnsInFairDates < ActiveRecord::Migration
  def self.up
    rename_column :fair_dates, :from, :from_date
    rename_column :fair_dates, :to, :to_date
  end

  def self.down
    rename_column :fair_dates, :from_date, :from
    rename_column :fair_dates, :to_date, :to
  end
end
