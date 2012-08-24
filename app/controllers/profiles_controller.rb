# -*- encoding : utf-8 -*-

class ProfilesController < ApplicationController
  before_filter :user_required
  before_filter :employee_required, :except => [:show_mine, :edit_mine, :update_mine,
      :edit_password, :update_password]
  
  def show_mine
    @user = @current_user
    @my_profile = true
    set_my_paths
    
    show_profile
  end
  
  def edit_mine
    @user = @current_user
    @my_profile = true
    set_my_paths
    
    edit_profile
  end
  
  def update_mine
    @user = @current_user
    @my_profile = true
    set_my_paths
    
    update_profile
  end
  
  def edit_password
    @user = @current_user
    @stylesheets = %w(message)
    @title = 'Passwort ändern'
  end
  
  def update_password
    @user = @current_user
    
    password_correct = @user.password == params[:password]
    new_passwords_match = params[:new_password] == params[:confirm_new_password]
    
    if password_correct and new_passwords_match
      @user.password = params[:new_password]
      
      if @user.save
        flash[:message].success "Passwort erfolgreich geändert!"
        
        redirect_to my_profile_path and return
      end
    end
    
    @user.errors.add :password, :incorrect  unless password_correct
    @user.errors.add :new_password, :confirmation  unless new_passwords_match
    
    @stylesheets = %w(message)
    @title = 'Passwort ändern'
    
    render :action => :edit_password
  end
  
  def index
    #TODO rely on default order
    @employees = Employee.all :order => 'name ASC'
    @customers = Customer.all :order => 'name ASC'
    
    @stylesheets = %w(profile)
    @title = "Profile"
  end
  
  def show
    @user = User.find_by_login params[:id]
    set_paths
    
    show_profile
  end
  
  def new
    @user = flash[:user] || params[:type].constantize.new
    params[:format] = nil
    
    set_new_paths
    @stylesheets = %w(message profile)
    @title = "Neues Profil erstellen"
    @method = :post
    
    render :edit
  end
  
  def create
    type = params[:profile][:type].constantize
    @user = type.create(params[:profile])
    @user.set_random_password
    
    if @user.save
      @user.create_confirm_registration_request
      flash[:message].success 'Profil wurde erstellt.'
      
      redirect_to profile_path(@user.login)
    else
      redirect_to new_profile_path(type), :flash => {:user => @user}
    end
  end
  
  def edit
    @user = User.find_by_login params[:id]
    set_paths
    
    edit_profile
  end
  
  def update
    @user = User.find_by_login params[:id]
    set_paths
    
    update_profile
  end
  
  def destroy
    @user = User.find_by_login!(params[:id])
    @user.destroy
    flash[:message].success "Das Profil von <b>#{@user.name}</b> wurde gelöscht."
    
    redirect_to profiles_path
  end

protected
  
#TODO from here on ...
  def type_as_param(type)
    t(type, :scope => [:activerecord, :models]).underscore
  end
  helper_method :type_as_param
  
  def new_profile_path type
    send "new_#{type.to_s.underscore}_profile_path".to_sym
  end
  helper_method :new_profile_path

  def show_profile
    @stylesheets = %w(message profile Markdown)
    @title = "#{@user.name}s Profil"
    
    render :show
  end
  
  def edit_profile
    @stylesheets = %w(message profile)
    @title = "#{@user.name}s Profil bearbeiten"
    @method = :put
    
    render :edit
  end
  
  def update_profile
    if @user.update_attributes params[:profile]
      flash[:message].success 'Profil wurde aktualisiert.'
      
      redirect_to (@my_profile ? my_profile_path : profile_path(@user.login))
    else
      edit_profile
    end
  end

  def set_my_paths
    @show_path = my_profile_path
    @edit_path = edit_my_profile_path
  end
  
  def set_paths
    @show_path = profile_path @user.login
    @edit_path = edit_profile_path @user.login
  end
  
  def set_new_paths
    @show_path = profiles_path
  end
end
