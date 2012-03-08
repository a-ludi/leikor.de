# -*- encoding : utf-8 -*-
class AddOrdToArticle < ActiveRecord::Migration
  def self.up
    add_column(:articles, :ord, :integer)
  end

  def self.down
    remove_column(:articles, :ord)
  end
end
