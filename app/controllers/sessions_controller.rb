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
    if user = User.find_by_login(params[:login]) and user.password == params[:password]
      login_user! user, :class => 'success', :title => 'Wilkommen!',
          :text => "Hallo, #{user.name}."
      redirect_to (params[:referer] || '/')
    else
      flash[:wrong_login_or_password] = true
      redirect_to new_session_path(:referer => params[:referer], :login => params[:login])
    end
  end

  def destroy
    logout_user! :class => 'info', :title => 'Bis bald!', :text => "… und auf Wiedersehen."
    redirect_to (request.referer.blank? ? '/' : request.referer)
  end
end
