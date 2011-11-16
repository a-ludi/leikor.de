class Category < ActiveRecord::Base
  PARAM_FORMAT = /\d+-[a-z0-9-]+/
  has_many :subcategories
  has_many :articles, :through => :subcategories, :order => 'name ASC'

  validates_presence_of :name
  validates_uniqueness_of :name
  
  def self.human_name
    'Kategorie'
  end
  
  def to_param
    transscription = {'ä' => 'ae', 'ö' => 'oe', 'ü' => 'ue', 'ß' => 'ss', '&' => 'und'}
    safe_name = name.downcase.gsub(/[äöüß&]/) { |match| transscription[match]}
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
end
