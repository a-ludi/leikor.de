# -*- encoding: utf-8 -*-

module ProfilesHelper
  def confirm_registration_url(user)
    edit_secure_user_request_url(user.confirm_registration_request.external_id)
  end
  
  def group_path(user, tag)
    profile_group_path(:profile_id => user.login, :id => tag.to_s)
  end
end
