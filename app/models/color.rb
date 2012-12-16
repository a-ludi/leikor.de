# -*- encoding: utf-8 -*-

class Color < ActiveRecord::Base
  include IgnoreIfAlreadyInCollectionExtension
  default_scope :order => 'label ASC'
  HEX_FORMAT = /^#([a-fA-F0-9]{3}|[a-fA-F0-9]{6})$/
  
  has_and_belongs_to_many :articles, :before_add => ignore_if_already_in_collection(:articles)

  validates_presence_of :label, :hex
  validates_uniqueness_of :label
  validates_format_of :hex, :with => HEX_FORMAT
  
  def to_param
    "#{id}-#{label.url_safe}"
  end
  
  def self.from_param(param)
    Color.find(param.to_i)
  end
end
