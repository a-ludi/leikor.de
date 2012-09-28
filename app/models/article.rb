# -*- encoding : utf-8 -*-

class Article < ActiveRecord::Base
  include UtilityHelper
  ARTICLE_NUMBER_FORMAT = /\d{5}\.\d{1,2}/
  UNITS = %w(mm cm dm m)
  default_scope :order => 'ord ASC'
  
  marked_up_with_maruku :description
  
  belongs_to :subcategory
  has_many :prices, :dependent => :destroy, :autosave => true
  has_and_belongs_to_many :colors, :before_add => :ignore_if_color_already_present,
      :after_remove => :removed_unused_color
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
  
  validates_size_of :prices, :minimum => 1, :message => :too_few
  validates_presence_of :name, :article_number, :subcategory
  validates_numericality_of :ord, :greater_than_or_equal_to => 0, :only_integer => true
  validates_numericality_of :width, :height, :depth, :greater_than => 0.0, :allow_nil => true
  validates_presence_of :unit, :if => :width_height_or_depth_present?
  validates_inclusion_of :unit, :in => Article::UNITS, :allow_nil => true
  validates_uniqueness_of :article_number
  validates_format_of :article_number, :with => UtilityHelper::delimited(ARTICLE_NUMBER_FORMAT)
  validates_markdown :description
  
  def html_id
    "artnr_#{article_number}".sub '.', '-'
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
  
private

  def ignore_if_color_already_present(color)
    raise ActiveRecord::Rollback if self.colors.include? color
  end
  
  def removed_unused_color(color)
    color.destroy if color.articles.empty?
  end
  
  def width_height_or_depth_present?
    self.width? or self.height? or self.depth?
  end
end
