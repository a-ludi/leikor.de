module ProfilesHelper
  def confirm_registration_url(user)
    request = user.secure_user_requests.find_by_action(:confirm_registration)
    secure_user_request_url(request.external_id)
  end
end
