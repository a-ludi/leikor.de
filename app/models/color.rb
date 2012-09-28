# -*- encoding: utf-8 -*-

class Color < ActiveRecord::Base
  default_scope :order => 'label ASC'
  HEX_FORMAT = /^#([a-fA-F0-9]{3}|[a-fA-F0-9]{6})$/
  
  has_and_belongs_to_many :articles, :before_add => :ignore_if_article_already_present

  validates_presence_of :label, :hex
  validates_uniqueness_of :label
  validates_format_of :hex, :with => HEX_FORMAT

private
  
  def ignore_if_article_already_present(article)
    raise ActiveRecord::Rollback if self.articles.include? article
  end
end
