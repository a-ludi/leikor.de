# -*- encoding : utf-8 -*-

class SecureUserRequest::ConfirmRegistration < SecureUserRequest
  LIFETIME = 7.days
end
