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
      when SecureUserRequest::ConfirmRegistration then mark_user_unconfirmed
      else unknown_type @secure_user_request
    end
    
    flash[:message] = {
      :class => 'success',
      :text => "#{@secure_user_request.class.human_name} wurde abgebrochen."
    }
    redirect_to :root
  end

private

  def new_reset_password
    @secure_user_request = SecureUserRequest::ResetPassword.new
    @stylesheets = ['message', 'sessions']
    @title = @secure_user_request.class.human_name
    
    render :action => 'reset_password/new'
  end
  
  def create_reset_password
    @user = User.find_by_login params[:login]
    if @user
      @secure_user_request = @user.reset_password_request || @user.create_reset_password_request
      success = @secure_user_request.touch
      # TODO deliver email
    end
    flash[:message] = { # TODO remove :class and link from message
        :class => success ? 'success' : 'error',
        :text => "<p>Bitte überprüfen Sie nun ihr Postfach.</p><p>Sollten Sie keine E-Mail erhalten
          haben, versuchen Sie es <b>nochmals</b> und überprüfen Sie ihren Benutzernamen auf
          <b>Tippfehler</b>.</p><p><a href='#{edit_secure_user_request_url(
          @secure_user_request.external_id)}'>Reset</a></p>".squish}
    
    redirect_to :root
  end
  
  def edit_reset_password
    @stylesheets = ['message', 'sessions']
    @title = t('activerecord.models.secure_user_request/reset_password')
    
    render :action => 'reset_password/edit'
  end
  
  def update_reset_password
    user = @secure_user_request.user
    passwords_match = params[:password] == params[:confirm_password]
    if passwords_match and user.update_attributes :password => params[:password]
      @secure_user_request.destroy
      login_user! user, :class => 'success', :title => 'Glückwunsch!', :text => 'Sie haben nun ein
          neues Passwort. Merken Sie es sich gut!'.squish
      
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
      
      flash[:message] = {
          :class => 'success',
          :text => "Der neue
              #{t('activerecord.models.secure_user_request/confirm_registration')}-Link wurde
              erstellt".squish}
    else
      flash[:message] = {
          :class => 'error',
          :title => 'Interner Fehler',
          :text => 'Der Benutzer konnte nicht gefunden werden. Bitte versuchen Sie es
              nochmals.'.squish}
    end
    
    redirect_to profile_path(@user.login)
  end
  
  def edit_confirm_registration
    @stylesheets = ['message', 'sessions']
    @title = t('activerecord.models.secure_user_request/confirm_registration')
    
    render :action => 'confirm_registration/edit'
  end
  
  def update_confirm_registration
    user = @secure_user_request.user
    passwords_match = params[:password] == params[:confirm_password]
    if passwords_match and user.update_attributes :password => params[:password]
      @secure_user_request.destroy
      login_user! user, :class => 'success', :title => 'Glückwunsch!', :text => render_to_string(
          :partial => 'secure_user_requests/confirm_registration/welcome',
          :locals => {:user => user})
      
      redirect_to my_profile_path
    else
      user.errors.add :password, :confirmation unless passwords_match
      edit_confirm_registration
    end
  end
  
  def mark_user_unconfirmed
    # TODO needs implementation
    logger.warn "[warning] SecureUserRequestsController.mark_user_unconfirmed needs implementation"
  end
  
  def get_and_set_secure_user_request
    external_id = params[:id]
    @secure_user_request = SecureUserRequest.find_by_external_id(external_id) or
        missing_secure_user_request
  end
  
  def missing_secure_user_request
    flash[:message] = {
      :title => 'Fehler',
      :class => 'error',
      :text => render_to_string(:partial => 'secure_user_requests/missing',
          :locals => {:external_id => params[:id]})
    }
    
    redirect_to (request.referer || :root) and return false
  end
  
  def force_user_logout
    logout_user! :class => 'error', :title => 'Bis bald!', :text => "Sie wurden abgemeldet, da
        eine #{SecureUserRequest.human_name} bearbeitet wird.".squish
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
