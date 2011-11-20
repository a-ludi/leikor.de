class StaticController < ApplicationController
  caches_page :show
  
  REGISTERED_PAGES = {
    'ueber_uns' => {:stylesheets => ['static']},
    'kontakt' => {:stylesheets => ['message']},
    'impressum' => {:stylesheets => ['message']},
    'AGB' =>  {:stylesheets => ['static']},
  }
  REGISTERED_PAGES['colors'] = {:stylesheets => ['static']} if RAILS_ENV == 'development'
  
  def show
    path = File.join params[:path] unless params[:path].nil?
    if REGISTERED_PAGES[path]
      @stylesheets = REGISTERED_PAGES[path][:stylesheets]
      render :action => path
    else
      raise ActionController::RoutingError, "No route matches \"/#{path}\" with {:method => :get}"
    end
  end
end
