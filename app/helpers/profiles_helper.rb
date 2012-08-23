# -*- encoding: utf-8 -*-

module ProfilesHelper
  def new_profile_path type
    send "new_#{type.to_s.underscore}_profile_path".to_sym
  end
  
  def confirm_registration_url(user)
    edit_secure_user_request_url(user.confirm_registration_request.external_id)
  end
  
  def group_path(user, tag)
    profile_group_path(:profile_id => user.login, :id => tag.to_s)
  end
end
