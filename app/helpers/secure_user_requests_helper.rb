module SecureUserRequestsHelper
  def request_url(request)
    edit_secure_user_request_url(request.external_id)
  end
end
