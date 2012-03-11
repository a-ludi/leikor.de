class SecureUserRequest < ActiveRecord::Base
  include Digest
  
  EXTERNAL_ID_FORMAT = /[a-f0-9]{32}/
  REGISTERED_ACTIONS = [:validate_register]
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
  end
end
