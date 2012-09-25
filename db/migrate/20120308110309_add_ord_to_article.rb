# -*- encoding : utf-8 -*-
class AddOrdToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :ord, :integer
    Article.reset_column_information
    Article.all.each_with_index do |article, idx|
      article.ord = idx + 1
      article.save
    end
  end

  def self.down
    remove_column :articles, :ord
  end
end
