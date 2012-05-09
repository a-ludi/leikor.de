# -*- encoding : utf-8 -*-

class Category < ActiveRecord::Base
  PARAM_FORMAT = /\d+-[a-z0-9-]+/
  OVERVIEW_COUNT = 4
  has_many :subcategories, :order => 'ord ASC', :dependent => :destroy
  has_many :articles, :through => :subcategories, :order => 'ord ASC'
  
  validates_presence_of :name
  validates_numericality_of :ord, :greater_than_or_equal_to => 0, :only_integer => true
  
  def self.human_name
    'Kategorie'
  end
  
  def to_param
    "#{id}-#{name.url_safe}"
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
    articles.find(:all, :limit => Category::OVERVIEW_COUNT, :order => 'ord ASC, RANDOM()')
  end
  
  def next_subcategory_ord
    if subcategory = subcategories.last(:order => 'ord ASC')
      subcategory.ord + 1
    else
      0
    end
  end
  
  def self.next_ord
    if category = Category.last(:order => 'ord ASC')
      category.ord + 1
    else
      0
    end
  end
end
