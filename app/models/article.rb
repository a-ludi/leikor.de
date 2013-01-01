# -*- encoding : utf-8 -*-

class Article < ActiveRecord::Base
  include UtilityHelper
  include IgnoreIfAlreadyInCollectionExtension
  ARTICLE_NUMBER_FORMAT = /\d{5}\.\d{1,2}/
  UNITS = %w(mm cm dm m)
  default_scope :order => 'ord ASC'
  
  marked_up_with_maruku :description
  
  belongs_to :subcategory
  acts_as_taggable_on :tags
  has_many :prices, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :prices, :allow_destroy => true
  before_validation_on_create :associate_article_to_prices
  has_and_belongs_to_many :colors, :before_add => ignore_if_already_in_collection(:colors),
      :after_remove => :removed_unused_color
  has_and_belongs_to_many :materials, :before_add => ignore_if_already_in_collection(:materials)
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
  validate :rising_minimum_count_means_falling_amount
  validates_presence_of :name, :article_number, :subcategory
  validates_numericality_of :ord, :greater_than_or_equal_to => 0, :only_integer => true
  validates_numericality_of :width, :height, :depth, :greater_than => 0.0, :allow_nil => true
  validates_presence_of :unit, :if => :width_height_or_depth_present?
  validates_inclusion_of :unit, :in => Article::UNITS, :allow_blank => true
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

protected
  
  def rising_minimum_count_means_falling_amount
    rising_minimum_counts = self.prices.sort do |a, b|
      sorting = a.minimum_count <=> b.minimum_count
    end
    falling_amounts = self.prices.sort do |a, b|
      -(a.amount <=> b.amount)
    end
    
    unless prices_amounts_and_minimum_counts_uniq? and rising_minimum_counts == falling_amounts
      self.errors.add :prices, :rising_minimum_count_means_falling_amount
    end
  end
  
private

  def prices_amounts_and_minimum_counts_uniq?
    amounts = self.prices.map{|p| p.amount}
    minimum_counts = self.prices.map{|p| p.minimum_count}
    
    amounts.count == amounts.uniq.count and minimum_counts.count == minimum_counts.uniq.count
  end

  def removed_unused_color(color)
    color.destroy if color.articles.empty?
  end
  
  def width_height_or_depth_present?
    self.width? or self.height? or self.depth?
  end
  
  def associate_article_to_prices
    self.prices.each{|price| price.article = self}
  end
end
