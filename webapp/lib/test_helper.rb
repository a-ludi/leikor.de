# -*- encoding : utf-8 -*-
module TestHelper
  def with_user(user=:john, session={})
    user = users(user) if user.is_a? Symbol
    session.merge(:user_id => user.id)
  end
  
  def deactivate_case(message='test-case deactivated')
    flunk message
  end
end
