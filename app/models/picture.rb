# -*- encoding : utf-8 -*-
class Picture < ActiveRecord::Base
  belongs_to :article
  has_attached_file(
    :picture,
    :storage => :database,
    :url => '/artikel/:article_id/bild/:ord/download/:style.:extension',
    :default_url => '/images/picture/:style/dummy.png',
    :styles => {
      :original => ['600x600>', :jpg],
      :micro_thumb => ['70x70#', :jpg],
      :thumb => ['150x150#', :jpg],
      :medium => ['300x300#', :jpg],
    }
  )
  PICTURE_INVALID_MESSAGE = 'scheint ungültig zu sein. Bitte wählen Sie ein
                             anderes. Falls der Fehler wieder auftritt,
                             informieren Sie bitte einen Administrator.'
  
  validates_numericality_of :ord, :greater_than_or_equal_to => 0, :only_integer => true
end
