module ProfilesHelper
  def confirm_registration_url(user)
    edit_secure_user_request_url(user.confirm_registration_request.external_id)
  end
end
