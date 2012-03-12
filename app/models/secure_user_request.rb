class SecureUserRequest < ActiveRecord::Base
  include Digest
  
  REGISTERED_ACTIONS = [:confirm_registration]
  MANDATORY_ARGUMENTS = [:action, :user_id]

  serialize :action, Symbol
  serialize :memo, Hash
  belongs_to :user

  validates_presence_of :action, :user_id
  validates_inclusion_of :action, :in => REGISTERED_ACTIONS
  
  def after_validation_on_create
    generate_external_id
  end

private
  
  def generate_external_id
    randomness_parameters = [
      self.action,
      self.user_id,
      self.memo,
      ActiveSupport::SecureRandom.base64(32)]
    
    self.external_id = Digest::MD5.hexdigest randomness_parameters.join
    
    generate_external_id unless SecureUserRequest.find_by_external_id(self.external_id).nil?
  end
end
