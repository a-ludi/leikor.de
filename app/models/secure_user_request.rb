# -*- encoding : utf-8 -*-

class SecureUserRequest < ActiveRecord::Base
  include Digest
  set_primary_key :external_id
  
  belongs_to :user

  validates_presence_of :type, :user_id
  
  after_validation_on_create :generate_id

  def lifetime
    self.class::LIFETIME
  end
  
  def expired?
    self.updated_at.since(lifetime).past?
  end

protected
  
  def generate_id
    self.id = Digest::MD5.hexdigest(ActiveSupport::SecureRandom.base64(32))
    
    generate_id if SecureUserRequest.exists? self.id
  end
end
