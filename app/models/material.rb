class Material < ActiveRecord::Base
  include IgnoreIfAlreadyInCollectionExtension
  
  default_scope :order => 'name ASC'
  
  has_and_belongs_to_many :articles, :before_add => ignore_if_already_in_collection(:articles)
  
  validates_presence_of :name
  validates_attachment_presence :picture
  validates_uniqueness_of :name
  has_attached_file(
    :picture,
    :storage => :database,
    :url => '/artikelmerkmale/materialien/:id/bild/:style.:extension',
    :default_url => '/images/picture/:style/material-missing.png',
    :styles => { :original => ['32x32#', :gif] }
  )
  
  def to_param
    "#{id}-#{name.url_safe}"
  end
  
  def self.from_param(param)
    Material.find(param.to_i)
  end
end
