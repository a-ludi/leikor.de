# -*- encoding : utf-8 -*-

class SessionsController < ApplicationController
#  include SslRequirement
#  ssl_required :new, :create
  before_filter :user_required, :only => [:destroy]
  
  def new
    @stylesheets = ['message', 'sessions']
    @title = 'Anmeldung'
    @login = params[:login] || session[:login]
    @referer = params[:referer] || request.referer
  end

  def create
    user = User.find_by_login(params[:login])
    password_correct = user.password == params[:password]
    
    if user and not user.registration?(:confirmed)
      flash[:message].error :partial => 'sessions/not_confirmed'
      
      redirect_to (params[:referer] || :root)
    elsif user and password_correct
      flash[:message].success "Hallo, #{user.name}.", 'Wilkommen!'
      login_user! user
      redirect_to (params[:referer] || :root)
    else
      flash[:wrong_login_or_password] = true
      redirect_to new_session_path(:referer => params[:referer], :login => params[:login])
    end
  end

  def destroy
    flash[:message].success '&hellip; und auf Wiedersehen.', 'Bis bald!'
    logout_user!
    redirect_to (request.referer.blank? ? '/' : request.referer)
  end
end
