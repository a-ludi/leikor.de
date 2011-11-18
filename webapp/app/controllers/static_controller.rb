class StaticController < ApplicationController
  caches_page :show
  
  REGISTERED_PAGES = {
    'ueber_uns' => {:stylesheets => ['static']},
    'kontakt' => {:stylesheets => ['message']},
    'impressum' => {:stylesheets => ['message']},
    'AGB' =>  {:stylesheets => ['static']},
    'colors' =>  {:stylesheets => ['static']}
  }
  
  def show
    path = File.join params[:path] unless params[:path].nil?
    if REGISTERED_PAGES[path]
      @stylesheets = REGISTERED_PAGES[path][:stylesheets]
      render :action => path
    else
      logger.warn "Tried to access unkown path '#{params[:path].inspect}'"
      render :file => File.join(Rails.root, 'public', '404.html'), :status => :not_found
    end
  end
end
