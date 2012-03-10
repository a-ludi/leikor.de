# -*- encoding : utf-8 -*-

class SessionsController < ApplicationController
#  include SslRequirement
#  ssl_required :new, :create
  before_filter :user_required, :only => [:destroy]
  
  def new
    @stylesheets = ['message', 'sessions']
    @title = 'Anmeldung'
    @login = session[:login] || params[:login]
    @referer = params[:referer] || request.referer
  end

  def create
    if @current_user = User.find_by_login(params[:login]) and @current_user.password == params[:password]
      session[:user_id] = @current_user.id
      session[:login] = @current_user.login
      flash[:message] = {
        :class => 'success',
        :title => 'Wilkommen!',
        :text => "Hallo, #{@current_user.name}."}
      redirect_to (params[:referer] || '/')
    else
      flash[:wrong_login_or_password] = true
      redirect_to new_session_path(:referer => params[:referer], :login => params[:login])
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
