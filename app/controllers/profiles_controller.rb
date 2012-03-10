class ProfilesController < ApplicationController
  before_filter :employee_required, :except => [:show_mine, :edit_mine, :update_mine]
  before_filter :user_required
  
  def show_mine
    @user = @current_user
    set_my_paths
    
    show_profile
  end
  
  def show
    @user = User.find_by_login params[:id]
    set_paths
    
    show_profile
  end
  
  def index
    @employees = Employee.all :order => 'name ASC'
    @customers = Customer.all :order => 'name ASC'
    
    @stylesheets = ['message', 'profile']
    @title = "Profile"
  end
  
  def edit_mine
    @user = @current_user
    set_my_paths
    
    edit_profile
  end
  
  def edit
    @user = User.find_by_login params[:id]
    set_paths
    
    edit_profile
  end
  
  def update_mine
    @user = @current_user
    set_my_paths
    
    update_profile
  end
  
  def update
    @user = User.find_by_login params[:id]
    set_paths
    
    update_profile
  end
  
private
  
  def show_profile
    @stylesheets = ['message', 'profile']
    @title = "#{@user.name}s Profil"
    
    render :show
  end
  
  def edit_profile
    @stylesheets = ['message', 'profile']
    @title = "#{@user.name}s Profil bearbeiten"
    
    render :edit
  end
  
  def update_profile
    if @user.update_attributes params[:profile]
      flash[:message] = {:text => 'Profil wurde aktualisiert.'}
      show_profile
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
end
