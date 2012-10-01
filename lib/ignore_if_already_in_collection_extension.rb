# -*- encoding : utf-8 -*-

module IgnoreIfAlreadyInCollectionExtension
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def ignore_if_already_in_collection(collection)
      Proc.new do |record, new_element|
        raise ActiveRecord::Rollback if record.send(collection.to_sym).include? new_element
      end
    end
  end
end
