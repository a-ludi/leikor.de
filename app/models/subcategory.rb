# -*- encoding : utf-8 -*-
class Subcategory < Category
  belongs_to :category
  has_many :articles, :order => 'name ASC'

  validates_presence_of :category_id, :message => 'activerecord.errors.messages.internal_error'
  
  def self.human_name
    'Unterkategorie'
  end
  
  def url_hash(options={})
    hash = {:subcategory => to_param}.merge(options)
    category.url_hash(hash)
  end
end
