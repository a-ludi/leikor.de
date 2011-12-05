class SessionsController < ApplicationController
  before_filter :login_required, :only => [:destroy]
  
  def new
    @stylesheets = ['message', 'sessions']
    @title = 'Anmeldung'
    flash[:referer] = request.referer || "/" if flash[:referer].blank?
  end

  def create
    if @current_user = User.find_by_login(params[:login]) and @current_user.password == params[:password]
      session[:user_id] = @current_user.id
      flash[:message] = {
        :class => 'success',
        :title => 'Wilkommen!',
        :text => "Hallo, #{@current_user.name}."}
      redirect_to (flash[:referer] || '/')
    else
      flash.keep
      flash[:wrong_login_or_password] = true
      flash[:login] = params[:login]
      redirect_to new_session_path
    end
  end

  def destroy
    session[:user_id] = @current_user = nil
    
    flash[:message] = {
      :class => 'info',
      :title => 'Bis bald!',
      :text => "… und auf Wiedersehen."}
    redirect_to (request.referer.blank? ? '/' : request.referer)
  end
end
