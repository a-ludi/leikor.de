# -*- encoding : utf-8 -*-

class SecureUserRequestsController < ApplicationController
  before_filter :get_and_set_secure_user_request, :destroy_if_expired, :except => [:new, :create]
  after_filter :force_user_logout
  
  def new
    action = params[:request_action].to_sym
    case action
      when :reset_password then new_reset_password
      else unknown_action action
    end
  end
  
  def create
    action = params[:secure_user_request][:action].to_sym
    case action
      when :reset_password then create_reset_password
      else unknown_action action
    end
  end
  
  def edit
    action = @secure_user_request.action
    case action
      when :confirm_registration then edit_confirm_registration
      when :reset_password then edit_reset_password
      else unknown_action action
    end
  end

  def update
    action = @secure_user_request.action
    case action
      when :confirm_registration then update_confirm_registration
      when :reset_password then update_reset_password
      else unknown_action action
    end
  end
  
  def destroy
    @secure_user_request.destroy
    flash[:message] = {
      :class => 'error',
      :text => "#{t "secure_user_request.#{@secure_user_request.action}"} abgebrochen."
    }
    redirect_to :root
  end

private

  def new_reset_password
    @secure_user_request = SecureUserRequest.new :action => :reset_password
    @stylesheets = ['message', 'sessions']
    @title = t('secure_user_request.reset_password')
    
    render :action => 'reset_password/new'
  end
  
  def create_reset_password
    @user = User.find_by_login params[:login]
    if @user
      @secure_user_request = @user.secure_user_requests.create :action => :reset_password
      success = true
    end
    flash[:message] = {
        :class => success ? 'success' : 'error',
        :text => "<p>Bitte überprüfen Sie nun ihr Postfach.</p><p>Sollten Sie keine E-Mail erhalten
          haben, versuchen Sie es <b>nochmals</b> und überprüfen Sie ihren Benutzernamen auf
          <b>Tippfehler</b>.</p><p><a href='#{edit_secure_user_request_url(
          @secure_user_request.external_id)}'>Reset</a></p>".squish}
    
    redirect_to :root
  end
  
  def edit_reset_password
    @stylesheets = ['message', 'sessions']
    @title = t('secure_user_request.reset_password')
    
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
  
  def edit_confirm_registration
    @stylesheets = ['message', 'sessions']
    @title = t('secure_user_request.confirm_registration')
    
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
        Sie eine #{SecureUserRequest.human_name} gestartet haben.".squish
  end
  
  def destroy_if_expired
    @secure_user_request.destroy and missing_secure_user_request if @secure_user_request.expired?
  end
  
  def unknown_action(action)
    not_found t('errors.controller.secure_user_requests.unknown_action', :action => action,
          :known_actions => SecureUserRequest::REGISTERED_ACTIONS.inspect), :log => true
  end
end
