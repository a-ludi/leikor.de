# -*- encoding : utf-8 -*-

class GroupsController < ApplicationController
  before_filter :employee_required, :make_groups, :make_user
  
  def create
    @user.group_list += @groups
    
    make_response "Gruppe erstellt"
  end
  
  def update
    @user.group_list -= @groups
    new_groups = groups_from_string params[:new_groups]
    @user.group_list += new_groups
    @groups = new_groups
    
    make_response "Gruppe geändert"
  end
  
  def destroy
    @user.group_list -= @groups
    
    make_response "Gruppe gelöscht"
  end

protected
  
  def make_groups
    @groups = groups_from_string params[:id]
  end
  
  def make_user
    @user = User.find_by_login! params[:profile_id]
  end
  
  def make_response success_message
    if @user.save
      flash[:message].success success_message
      
      respond_to do |format|
        format.js do
          render :text => @groups.join(', ')
        end
        
        format.html do
          redirect_to profile_path(@user)
        end
      end
    else
      flash[:message].error make_if_error_messages_for(@user)
      
      respond_to do |format|
        format.js do
          render :partial => 'layouts/push_message'
        end
        
        format.html do
          redirect_to profile_path(@user)
        end
      end
    end
  end
  
  def groups_from_string(string)
    string.split(',').map{|g| g.strip}
  end
end
