# -*- encoding : utf-8 -*-

class SecureUserRequestsController < ApplicationController
  ssl_required_by_all_actions
  before_filter :fetch_secure_user_request, :destroy_request_if_expired
  before_filter :force_user_logout, :except => [:new, :create]
  
  def new
    case @secure_user_request
      when SecureUserRequest::ResetPassword then new_reset_password
    end
  end
  
  def create
    case @secure_user_request
      when SecureUserRequest::ResetPassword then create_reset_password
      when SecureUserRequest::ConfirmRegistration then create_confirm_registration
    end
  end
  
  def edit
    case @secure_user_request
      when SecureUserRequest::ConfirmRegistration then edit_confirm_registration
      when SecureUserRequest::ResetPassword then edit_reset_password
    end
  end

  def update
    case @secure_user_request
      when SecureUserRequest::ConfirmRegistration then update_confirm_registration
      when SecureUserRequest::ResetPassword then update_reset_password
    end
  end
  
  def destroy
    case @secure_user_request.destroy
      when SecureUserRequest::ConfirmRegistration
        @secure_user_request.user.registration = :denied
        @secure_user_request.user.save
      when SecureUserRequest::ResetPassword then nil
    end
    
    flash[:message] << "#{@secure_user_request.class.human_name} wurde abgebrochen."
    
    redirect_to :root
  end

protected

  def new_reset_password
    @stylesheets = ['message']
    @title = @secure_user_request.class.human_name
    
    render :action => 'reset_password/new'
  end
  
  def create_reset_password
    @user = User.find_by_login params[:login]
    
    # independed of success this should be displayed to disguise wether or not that user exists
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
    @user = @secure_user_request.user
    passwords_match = params[:password] == params[:confirm_password]
    if passwords_match and @user.update_attributes :password => params[:password]
      @secure_user_request.destroy
      flash[:message].success 'Sie haben nun ein neues Passwort. Merken Sie es sich gut!',
          'Glückwunsch!'
      login_user! @user
      
      redirect_to :root
    else
      @user.errors.add :password, :confirmation unless passwords_match
      edit_reset_password
    end
  end
  
  def create_confirm_registration
    employee_required or return
    
    @user = User.find_by_login! params[:login]
    @secure_user_request = @user.confirm_registration_request ||
        @user.create_confirm_registration_request
    @secure_user_request.touch
    
    if params[:sendmail]
      Notifier.deliver_confirm_registration_request @user
      flash[:message].success 'Die E-Mail wurde versandt'
    else
      flash[:message].success "Die Anfrage „
          #{t('activerecord.models.secure_user_request/confirm_registration')}“ wurde
          erstellt".squish
    end
    
    respond_to do |format|
      format.html { redirect_to profile_path(@user.login) }
      format.js { render :partial => 'layouts/push_message' }
    end
  end
  
  def edit_confirm_registration
    @stylesheets = ['message']
    @title = t('activerecord.models.secure_user_request/confirm_registration')
    
    render :action => 'confirm_registration/edit'
  end
  
  def update_confirm_registration
    @user = @secure_user_request.user
    passwords_match = params[:password] == params[:confirm_password]
    if passwords_match and @user.update_attributes :password => params[:password]
      @secure_user_request.destroy
      flash[:message].success :partial => 'secure_user_requests/confirm_registration/welcome',
          :locals => {:user => @user}
      flash[:message].title = 'Glückwunsch!'
      login_user! @user
      
      redirect_to my_profile_path
    else
      @user.errors.add :new_password, :confirmation unless passwords_match
      edit_confirm_registration
    end
  end
  
  def fetch_secure_user_request
    @secure_user_request = if params.include? :id
          SecureUserRequest.find_by_external_id(params[:id]) or missing_secure_user_request
        else
          params[:type].constantize.new
        end
  end
  
  def missing_secure_user_request
    flash[:message].error :partial => 'secure_user_requests/missing', :locals => {:external_id =>
        params[:id]}
    
    redirect_to (request.referer || :root) and return false
  end
  
  def force_user_logout
    #TODO use translation
    flash[:message].error "Sie wurden abgemeldet, da eine #{SecureUserRequest.human_name} bearbeitet
        wird.".squish, 'Bis bald!' if logged_in?
    logout_user!
  end
  
  def destroy_request_if_expired
    if not @secure_user_request.new_record? and @secure_user_request.expired?
      @secure_user_request.destroy and missing_secure_user_request
    end
  end
end
