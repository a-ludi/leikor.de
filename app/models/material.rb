class Material < ActiveRecord::Base
  include IgnoreIfAlreadyInCollectionExtension
  
  has_and_belongs_to_many :articles, :before_add => ignore_if_already_in_collection(:articles)
end
