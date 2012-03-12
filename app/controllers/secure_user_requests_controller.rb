class SecureUserRequestsController < ApplicationController
  def edit
    get_and_set_secure_user_request
    
    case @secure_user_request.action
      when :confirm_registration
        edit_confirm_registration
      else
        not_found("SecureUserRequest action <#{@secure_user_request.action.inspect}> not known. " +
            "Should be one of <#{SecureUserRequest::REGISTERED_ACTIONS.inspect}>", true)
    end
  end

  def update
    get_and_set_secure_user_request
    
    case @secure_user_request.action
      when :confirm_registration
        update_confirm_registration
      else
        not_found
    end
  end

private
  
  def edit_confirm_registration
    @stylesheets = ['message']
    @title = t('secure_user_request.confirm_registration')
    
    render :action => 'confirm_registration/edit'
  end
  
  def update_confirm_registration
    redirect_to profile_path(@secure_user_request.user.login)
  end
  
  def get_and_set_secure_user_request
    external_id = params[:id]
    @secure_user_request = SecureUserRequest.find_by_external_id(external_id) or
        not_found("No SecureUserRequest with external ID <#{external_id.inspect}> found", true)
  end
end
