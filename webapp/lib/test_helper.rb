module TestHelper
  def with_user(user=:john, session={})
    user = users(user) if user.is_a? Symbol
    session.merge(:user_id => user.id)
  end
end
