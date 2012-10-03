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
    :url => '/material/:id/bild/download/:style.:extension',
    :styles => { :original => ['600x600#', :gif] }
  )
end
