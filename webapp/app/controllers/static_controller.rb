class StaticController < ApplicationController
  caches_page :show
  
  REGISTERED_PAGES = {
    :ueber_uns => {:name => 'Über uns', :stylesheets => ['static']},
    :kontakt => {:name => 'Kontakt', :stylesheets => ['message', 'static/kontakt']},
    :impressum => {:name => 'Impressum', :stylesheets => ['message', 'static/kontakt']},
    :AGB =>  {:name => 'AGB', :stylesheets => ['static', 'static/kontakt']},
    :messetermine => {:name => 'Messetermine', :stylesheets => ['static', 'static/messetermine']},
  }
  REGISTERED_PAGES[:colors] = {:name => 'Farbpalette', :stylesheets => ['static']} if RAILS_ENV == 'development'
  
  def show
    path = File.join(params[:path].to_s).to_sym unless params[:path].nil?
    if REGISTERED_PAGES[path]
      @stylesheets = REGISTERED_PAGES[path][:stylesheets]
      @title = REGISTERED_PAGES[path][:name]
      @page = REGISTERED_PAGES[path]
      render :action => path
    else
      raise ActionController::RoutingError, "No route matches \"/#{path.inspect}\" with {:method => :get}"
    end
  end
end
