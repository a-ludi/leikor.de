# -*- encoding : utf-8 -*-

class SessionsController < ApplicationController
  ssl_required_by_all_actions
  before_filter :user_required, :only => [:destroy]
  
  def new
    @stylesheets = %w(message form)
    @title = 'Anmeldung'
    @login = flash[:login] || session[:login]
    @referer = params[:referer] || flash[:referer] || request.referer
  end

  def create
    user = User.find_by_login params[:login]
    
    if user and not user.registration?(:confirmed)
      flash[:message].error :partial => 'sessions/not_confirmed'
      
      redirect_to (params[:referer] || :root)
    elsif user and user.password == params[:password]
      flash[:message].success "Hallo, #{user.name}.", 'Wilkommen!'
      login_user! user
      redirect_to (params[:referer] || :root)
    else
      flash.update(
          :wrong_login_or_password => true,
          :referer => params[:referer],
          :login => params[:login])
      redirect_to new_session_path
    end
  end

  def destroy
    flash[:message].success '&hellip; und auf Wiedersehen.', 'Bis bald!'
    logout_user!
    redirect_to :root
  end
end
