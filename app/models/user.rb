# -*- encoding : utf-8 -*-
require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt
  LOGIN_FORMAT = /^[a-zA-Z][a-zA-Z_.-]*$/
  unless RAILS_ENV == 'development'
    EMAIL_FORMAT = /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,6}$/i
  else
    EMAIL_FORMAT = /^[A-Z0-9._%+-]+@localhost$/i
  end
  
  acts_as_taggable_on :marks
  has_one :reset_password_request,
      :class_name => 'SecureUserRequest::ResetPassword',
      :dependent => :delete
  has_one :confirm_registration_request,
      :class_name => 'SecureUserRequest::ConfirmRegistration',
      :dependent => :delete
  
  validates_presence_of :login, :password, :name, :type, :primary_email_address
  validates_format_of :primary_email_address, :with => User::EMAIL_FORMAT, :message => 'hat ein falsches Format.'
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
  
  def set_random_password
    self.password = ActiveSupport::SecureRandom.base64(32)
  end
  
  def registration?(state)
    case state
      when :confirmed then self.confirm_registration_request.nil?
      when :denied then self.mark_list.include? 'ConfirmRegistration'
      else throw ArgumentError.new "Unknown state <#{state.inspect}> in User.registration?"
    end
  end
  
protected
  
  def save_password_length(password)
    @password_length = password.to_s.length
  end
  
  def password_length
    @password_length.to_i
  end

  def password_longer_than
    errors.add :password, :'too_short', :count => 6 unless @password_length.nil? or  @password_length >= 6
  end
end
