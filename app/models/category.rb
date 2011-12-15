# -*- encoding : utf-8 -*-
class Category < ActiveRecord::Base
  URL_TRANSSCRIPTION = {'ä' => 'ae', 'ö' => 'oe', 'ü' => 'ue', 'ß' => 'ss', '&' => 'und'}
  PARAM_FORMAT = /\d+-[a-z0-9-]+/
  has_many :subcategories, :order => 'ord ASC'
  has_many :articles, :through => :subcategories, :order => 'name ASC'
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :ord, :greater_than_or_equal_to => 0, :only_integer => true
  
  def self.human_name
    'Kategorie'
  end
  
  def to_param
    safe_name = name.downcase
    URL_TRANSSCRIPTION.each { |match, replacement| safe_name.gsub! match, replacement }
    safe_name = safe_name.gsub(/[^a-zA-Z0-9]+/, '-').gsub(/(^-+|-+$)/, '')
    "#{id}-#{safe_name}"
  end
  
  def self.from_param(param)
    Category.find(param.to_i)
  end

  def url_hash(options={})
    {:category => to_param}.merge(options)
  end
  
  def html_id
    "#{self.class.name.underscore}_#{id}"
  end
  
  def overview
    articles.find(:all, :limit => 4, :order => 'RANDOM()')
  end
  
protected
  
  def self.next_ord
    if category = Category.first(:order => 'ord DESC')
      category.ord + 1
    else
      0
    end
  end
end
