# -*- encoding : utf-8 -*-

class Article < ActiveRecord::Base
  include UtilityHelper
  ARTICLE_NUMBER_FORMAT = /\d{5}\.\d{1,2}/
  
  marked_up_with_maruku :description
  
  belongs_to :subcategory
  has_attached_file(
    :picture,
    :storage => :database,
    :url => '/artikel/:id/bild/download/:style.:extension',
    :default_url => '/images/picture/:style/dummy.png',
    :styles => {
      :original => ['600x600>', :jpg],
      :thumb => ['150x150#', :jpg],
      :medium => ['300x300#', :jpg],
    }
  )
  PICTURE_INVALID_MESSAGE = 'scheint ungültig zu sein. Bitte wählen Sie ein
                             anderes. Falls der Fehler wieder auftritt,
                             informieren Sie bitte einen Administrator.'
  
  validates_presence_of :name, :price, :article_number, :subcategory
  validates_numericality_of :price, :greater_than => 0.0
  validates_numericality_of :ord, :greater_than_or_equal_to => 0, :only_integer => true
  validates_uniqueness_of :article_number
  validates_format_of :article_number, :with => UtilityHelper::delimited(ARTICLE_NUMBER_FORMAT)
  validates_markdown :description
  
  def html_id
    "artnr_#{article_number}".sub '.', '_'
  end
  
  def url_hash(options={})
    hash = {:article => article_number}.merge(options)
    subcategory.url_hash(hash)
  end
  
  def format(attribute)
    if attribute === :price
      ('%.2f' % price).sub '.', ','
    else
      read_attribute(attribute)
    end
  end
  
protected
  
  def self.next_ord(subcategory_id)
    if article = Article.last(:order => 'ord ASC', :conditions => ["subcategory_id = ?", subcategory_id])
      article.ord + 1
    else
      0
    end
  end
end
