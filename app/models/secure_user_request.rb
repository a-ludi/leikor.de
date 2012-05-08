# -*- encoding : utf-8 -*-

class SecureUserRequest < ActiveRecord::Base
  include Digest
  
  belongs_to :user

  validates_presence_of :type, :user_id
  
  after_validation_on_create :generate_external_id

  def lifetime
    self.class::LIFETIME
  end
  
  def expired?
    self.updated_at.since(lifetime).past?
  end

protected
  
  def generate_external_id
    randomness_parameters = [
      self.class,
      self.user_id,
      self.memo,
      ActiveSupport::SecureRandom.base64(32)]
    
    self.external_id = Digest::MD5.hexdigest randomness_parameters.join
    
    generate_external_id unless SecureUserRequest.find_by_external_id(self.external_id).nil?
  end
end
