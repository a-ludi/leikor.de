# -*- encoding : utf-8 -*-

class SecureUserRequestsController < ApplicationController
  before_filter :get_and_set_secure_user_request, :destroy_if_expired, :except => [:new, :create]
  before_filter :force_user_logout, :except => [:new, :create]
  
  def new
    type = get_type_from_params
    case type
      when SecureUserRequest::ResetPassword then new_reset_password
      else unknown_type type
    end
  end
  
  def create
    type = get_type_from_params
    case type
      when SecureUserRequest::ResetPassword then create_reset_password
      when SecureUserRequest::ConfirmRegistration then create_confirm_registration
      else unknown_type type
    end
  end
  
  def edit
    case @secure_user_request
      when SecureUserRequest::ConfirmRegistration then edit_confirm_registration
      when SecureUserRequest::ResetPassword then edit_reset_password
      else unknown_type @secure_user_request
    end
  end

  def update
    case @secure_user_request
      when SecureUserRequest::ConfirmRegistration then update_confirm_registration
      when SecureUserRequest::ResetPassword then update_reset_password
      else unknown_type @secure_user_request
    end
  end
  
  def destroy
    case @secure_user_request.destroy
      when SecureUserRequest::ConfirmRegistration
        @secure_user_request.user.registration = :denied
        @secure_user_request.user.save
      when SecureUserRequest::ResetPassword then nil
      else unknown_type @secure_user_request
    end
    
    flash[:message] << "#{@secure_user_request.class.human_name} wurde abgebrochen."
    
    redirect_to :root
  end

protected

  def new_reset_password
    @secure_user_request = SecureUserRequest::ResetPassword.new
    @stylesheets = ['message']
    @title = @secure_user_request.class.human_name
    
    render :action => 'reset_password/new'
  end
  
  def create_reset_password
    @user = User.find_by_login params[:login]
    
    flash[:message].success :partial => 'secure_user_requests/reset_password/success'
    
    if @user
      if @user.confirm_registration_request.nil?
        @secure_user_request = @user.reset_password_request || @user.create_reset_password_request
        @secure_user_request.touch
        Notifier.deliver_reset_password_request @user
      else
        flash[:message].error :partial => 'sessions/not_confirmed'
      end
    end
    
    redirect_to :root
  end
  
  def edit_reset_password
    @stylesheets = ['message']
    @title = t('activerecord.models.secure_user_request/reset_password')
    
    render :action => 'reset_password/edit'
  end
  
  def update_reset_password
    user = @secure_user_request.user
    passwords_match = params[:password] == params[:confirm_password]
    if passwords_match and user.update_attributes :password => params[:password]
      @secure_user_request.destroy
      flash[:message].success 'Sie haben nun ein neues Passwort. Merken Sie es sich gut!',
          'Glückwunsch!'
      login_user! user
      
      redirect_to :root
    else
      user.errors.add :password, :confirmation unless passwords_match
      edit_reset_password
    end
  end
  
  def create_confirm_registration
    if @user = User.find_by_login(params[:login])
      @secure_user_request = @user.confirm_registration_request ||
          @user.create_confirm_registration_request
      @secure_user_request.touch
      
      if params[:sendmail]
        Notifier.deliver_confirm_registration_request @user
        flash[:message].success 'Die E-Mail wurde versandt'
      else
        flash[:message].success "Die Anfrage \"
            #{t('activerecord.models.secure_user_request/confirm_registration')}\" wurde
            erstellt".squish
      end
    else
      flash[:message].error 'Der Benutzer konnte nicht gefunden werden. Bitte versuchen Sie es
          nochmals.'.squish, 'Interner Fehler'
    end
    
    redirect_to profile_path(@user.login)
  end
  
  def edit_confirm_registration
    @stylesheets = ['message']
    @title = t('activerecord.models.secure_user_request/confirm_registration')
    
    render :action => 'confirm_registration/edit'
  end
  
  def update_confirm_registration
    user = @secure_user_request.user
    passwords_match = params[:password] == params[:confirm_password]
    if passwords_match and user.update_attributes :password => params[:password]
      @secure_user_request.destroy
      flash[:message].success :partial => 'secure_user_requests/confirm_registration/welcome',
          :locals => {:user => user}
      flash[:message].title = 'Glückwunsch!'
      login_user! user
      
      redirect_to my_profile_path
    else
      user.errors.add :new_password, :confirmation unless passwords_match
      edit_confirm_registration
    end
  end
  
  def get_and_set_secure_user_request
    external_id = params[:id]
    @secure_user_request = SecureUserRequest.find_by_external_id(external_id) or
        missing_secure_user_request
  end
  
  def missing_secure_user_request
    flash[:message].error :partial => 'secure_user_requests/missing', :locals => {:external_id =>
        params[:id]}
    
    redirect_to (request.referer || :root) and return false
  end
  
  def force_user_logout
    flash[:message].error "Sie wurden abgemeldet, da eine #{SecureUserRequest.human_name} bearbeitet
        wird.".squish, 'Bis bald!'
    logout_user!
  end
  
  def destroy_if_expired
    @secure_user_request.destroy and missing_secure_user_request if @secure_user_request.expired?
  end
  
  def unknown_type(type)
    not_found t('errors.controller.secure_user_requests.unknown_type', :type => type),
        :log => true
  end
  
  def get_type_from_params
    params[:type].constantize.new
  end
end
