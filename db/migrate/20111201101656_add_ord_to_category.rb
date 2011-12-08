# -*- encoding : utf-8 -*-
class AddOrdToCategory < ActiveRecord::Migration
  def self.up
    add_column(:categories, :ord, :integer)
  end
  
  def self.down
    remove_column(:categories, :ord)
  end
end
