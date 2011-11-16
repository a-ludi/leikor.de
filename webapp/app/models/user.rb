require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt
  LOGIN_FORMAT = /^[a-zA-Z][a-zA-Z_.-]*$/
  
  validates_presence_of :login, :password, :name
  validates_length_of :login, :in => 4..32
  validates_format_of :login, :with => User::LOGIN_FORMAT, :message => 'muss mit einem Groß-/Kleinbuchstaben beginnen und darf nur aus Groß-/Kleinbuchstaben und den Zeichen <tt>._-</tt> bestehen.'
  validates_uniqueness_of :login
  validate :password_longer_than
  
  def password
    @password ||= Password.new(self[:password]) unless self[:password].blank?
  end

  def password=(new_password)
    return if new_password.blank?
    
    save_password_length new_password
    @password = Password.create(new_password)
    self[:password] = @password
  end

protected
  
  def save_password_length(password)
    @password_length = password.to_s.length
  end
  
  def password_length
    @password_length.to_i
  end

  def password_longer_than
    errors.add :password, :'too_short', :count => 6 unless self.password_length >= 6
  end
end
