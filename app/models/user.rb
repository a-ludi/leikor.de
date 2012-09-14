# -*- encoding : utf-8 -*-

class User < ActiveRecord::Base
  include BCrypt
  LOGIN_FORMAT = /^[a-zA-Z][a-zA-Z-]*$/
  EMAIL_FORMAT = /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,6}$/i
  
  marked_up_with_maruku :notes
  # TODO untested `acts_as_taggable_on :marks, :groups`; how to?
  acts_as_taggable_on :marks, :groups
  has_one :reset_password_request,
      :class_name => 'SecureUserRequest::ResetPassword',
      :dependent => :delete
  has_one :confirm_registration_request,
      :class_name => 'SecureUserRequest::ConfirmRegistration',
      :dependent => :delete
  has_many :owned_blog_posts, :class_name => 'BlogPost', :foreign_key => 'author_id', :order => 'created_at DESC'
  has_many :edited_blog_posts, :class_name => 'BlogPost', :foreign_key => 'editor_id', :order => 'created_at DESC'
  
  validates_presence_of :name, :login, :password, :type, :primary_email_address
  # TODO replace message with translated version
  validates_format_of :primary_email_address, :with => User::EMAIL_FORMAT, :message => 'hat ein
      falsches Format.'.squish
  validates_length_of :login, :in => 4..32
  # TODO replace message with translated version
  validates_format_of :login, :with => User::LOGIN_FORMAT, :message => 'muss mit einem
      Groß-/Kleinbuchstaben beginnen und darf nur aus Groß-/Kleinbuchstaben und den Zeichen
      <tt>.-</tt> bestehen.'.squish
  validates_uniqueness_of :login
  validate :password_longer_than
  # TODO test `validates_markdown :notes`; how to? 
  validates_markdown :notes
  
  def password
    @password ||= Password.new(self[:password]) unless self[:password].blank?
  end

  def password=(new_password)
    save_password_length new_password
    
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
      else raise ArgumentError.new "Unknown state <#{state.inspect}> in User.registration?"
    end
  end
  
  def registration=(state)
    case state
      when :denied
        unless self.registration? :confirmed
          self.mark_list << 'ConfirmRegistration'
        else
          raise "must not deny already confirmed registrations; user id=#{id}"
        end
      else raise ArgumentError.new "Unknown state <#{state.inspect}> in User.registration="
    end
  end
  
  def email_address_with_name(id=:primary)
    case id
      when :primary
        email_address = self.primary_email_address
        name = self.name
      else
        logger.warn "[warning] not implemented <User#email_address_with_name> with <#{id}> given"
    end
    
    "\"#{name}\" <#{email_address}>"
  end
  
protected
  
  def save_password_length(password)
    @password_length = password.to_s.length
  end
  
  def password_length
    @password_length.to_i
  end

  def password_longer_than
    errors.add :password, :'too_short', :count => 6 unless @password_length.nil? or @password_length >= 6
  end
end
