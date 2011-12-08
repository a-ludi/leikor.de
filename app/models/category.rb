# -*- encoding : utf-8 -*-
class Category < ActiveRecord::Base
  URL_TRANSSCRIPTION = {'ä' => 'ae', 'ö' => 'oe', 'ü' => 'ue', 'ß' => 'ss', '&' => 'und'}
  PARAM_FORMAT = /\d+-[a-z0-9-]+/
  has_many :subcategories, :order => 'ord ASC'
  has_many :articles, :through => :subcategories, :order => 'name ASC'

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :ord
  validates_numericality_of :ord, :greater_than_or_equal_to => 1, :only_integer => true
  
  def self.human_name
    'Kategorie'
  end
  
  def to_param
    #FIXME encoding stuff
    safe_name = name.force_encoding('UTF-8').downcase
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
    "#{self.class.to_s}_#{id}"
  end
  
  def overview
    articles.find(:all, :limit => 4, :order => 'RANDOM()')
  end

protected
  def safe_encode(string)
    string.force_encoding Encoding.default_internal unless string.valid_encoding?
  end
end