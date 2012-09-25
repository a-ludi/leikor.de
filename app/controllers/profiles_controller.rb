# -*- encoding : utf-8 -*-

class ProfilesController < ApplicationController
  before_filter :user_required
  before_filter :employee_required, :except => [:show_mine, :edit_mine, :update_mine,
      :edit_password, :update_password]
  before_filter :set_my_profile, :only => [:show_mine, :edit_mine, :update_mine, :edit_password,
      :update_password]
  before_filter :set_profile, :except => [:index, :new, :create]
  
  def index
    #TODO rely on default order
    @customers = Customer.all
    @employees = Employee.all
    
    @stylesheets = %w(profile)
    @title = "Profile"
  end
  
  def show
    @stylesheets = %w(message profile Markdown)
    @title = "#{@profile.name}s Profil"
    
    render :show
  end
  alias :show_mine  :show
  
  def new
    @profile = flash[:profile] || params[:type].constantize.new
    
    @stylesheets = %w(message profile form)
    @title = "Neues Profil erstellen"
    
    render :edit
  end
  
  def create
    type = params[:profile][:type].constantize
    @profile = type.create(params[:profile])
    @profile.set_random_password
    
    if @profile.save
      @profile.create_confirm_registration_request
      flash[:message].success 'Profil wurde erstellt.'
      
      redirect_to profile_path(@profile.login)
    else
      redirect_to new_profile_path(type), :flash => {:profile => @profile}
    end
  end
  
  def edit
    @stylesheets = %w(message profile form)
    @title = "#{@profile.name}s Profil bearbeiten"
    
    render :edit
  end
  alias :edit_mine  :edit
  
  def update
    if @profile.update_attributes params[:profile]
      flash[:message].success 'Profil wurde aktualisiert.'
      
      redirect_to show_path
    else
      redirect_to edit_path, :flash => {:profile => @profile}
    end
  end
  alias :update_mine  :update
  
  def edit_password
    @stylesheets = %w(message)
    @title = 'Passwort ändern'
  end
  
  def update_password
    password_correct = @profile.password == params[:password]
    new_passwords_match = params[:new_password] == params[:confirm_new_password]
    @profile.password = params[:new_password]
    
    if password_correct and new_passwords_match and @profile.save
        flash[:message].success "Passwort erfolgreich geändert!"
        
        redirect_to my_profile_path
    else
      @profile.errors.add :password, :incorrect  unless password_correct
      @profile.errors.add :new_password, :confirmation  unless new_passwords_match
      
      redirect_to edit_password_path, :flash => {:profile => @profile}
    end
  end
  
  def destroy
    @profile.destroy
    flash[:message].success "Das Profil von <b>#{@profile.name}</b> wurde gelöscht."
    
    redirect_to profiles_path
  end
  
protected
  
  def new_profile_path type
    send "new_#{type.to_s.underscore}_profile_path".to_sym
  end
  helper_method :new_profile_path
  
  def show_path
    if @profile.new_record?
      profiles_path
    elsif @my_profile
      my_profile_path
    else
      profile_path @profile.login
    end
  end
  helper_method :show_path

  def edit_path
    if @my_profile
      edit_my_profile_path
    else
      edit_profile_path @profile.login
    end
  end
  helper_method :edit_path

  def set_my_profile
    @my_profile = true
  end
  
  def set_profile
    @profile = flash[:profile] || (@my_profile ? @current_user : User.find_by_login!(params[:id]))
  end
end
