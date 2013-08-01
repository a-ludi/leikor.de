# -*- encoding : utf-8 -*-

class GroupsController < ApplicationController
  before_filter :employee_required
  before_filter :make_groups, :fetch_user, :only => [:create, :update, :destroy]

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

  def suggest
    pattern = escape_like_pattern(params[:token]) + '%'
    @suggestions = User.group_counts :conditions => ['name ILIKE ?', pattern], :limit => 10

    render :layout => false
  end

protected

  def make_groups
    @groups = groups_from_string params[:id]
  end

  def fetch_user
    @user = User.find_by_login! params[:profile_id]
  end

  def make_response success_message
    if @user.save
      flash[:message].success success_message

      respond_to do |format|
        format.html do
          flash.keep

          redirect_to profile_path(@user)
        end

        format.js do
          render :text => @groups.join(', ')
        end
      end
    else
      logger.warn '[warn] statement should not be reached; errors on User record found'
      flash[:message].error make_if_error_messages_for(@user)

      respond_to do |format|
        format.html do
          flash.keep

          redirect_to profile_path(@user)
        end

        format.js do
          render :partial => 'layouts/push_message'
        end
      end
    end
  end

  def groups_from_string(string)
    string.split(',').map{|g| g.strip}
  end
end
