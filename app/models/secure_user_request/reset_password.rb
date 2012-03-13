# -*- encoding : utf-8 -*-

class SecureUserRequest::ResetPassword < SecureUserRequest
  LIFETIME = 3.days
end
