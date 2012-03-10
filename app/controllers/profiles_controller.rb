class ProfilesController < ApplicationController
  before_filter :employee_required, :except => [:show_mine]
  before_filter :user_required
  
  def show_mine
    @user = @current_user
    
    show_profile
  end
  
  def show
    @user = User.find_by_login params[:id]
    
    show_profile
  end
  
  def index
    @employees = Employee.all :order => 'name ASC'
    @customers = Customer.all :order => 'name ASC'
    
    @stylesheets = ['message', 'profile']
    @title = "Profile"
  end
  
private
  
  def show_profile
    @stylesheets = ['message', 'profile']
    @title = "#{@user.name}s Profil"
  end
end
