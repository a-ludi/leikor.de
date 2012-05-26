# -*- encoding : utf-8 -*-

class StaticController < ApplicationController
  skip_before_filter :prepare_flash_message
  caches_page :page, :stylesheet
  
  REGISTERED_PAGES = {
    :'ueber-uns' => {:name => 'Über uns', :stylesheets => %w(static)},
    :kontakt => {:name => 'Kontakt', :stylesheets =>
        %w(message static/kontakt)},
    :impressum => {:name => 'Impressum', :stylesheets =>
        %w(message static static/kontakt)},
    :AGB =>  {:name => 'AGB', :stylesheets => %w(static static/kontakt)},
    :fehlt =>  {:name => 'Implementierung fehlt', :stylesheets => %w(message)},
    :'hilfe/Markdown' => {:name => 'Markdown (Hilfe)', :stylesheets =>
        %w(static Markdown)}
  }
  REGISTERED_PAGES[:colors] = {:name => 'Farbpalette', :stylesheets =>
      %w(static)} if RAILS_ENV == 'development'
  
  STYLESHEETS_PATH = File.join Rails.root, 'app', 'views', 'stylesheets'
  append_view_path STYLESHEETS_PATH
  
  def show
    path = File.join(params[:path]).to_sym unless params[:path].nil?
    
    if REGISTERED_PAGES[path]
      @stylesheets = REGISTERED_PAGES[path][:stylesheets] || []
      @title = REGISTERED_PAGES[path][:name] unless params[:welcome]
      @page = REGISTERED_PAGES[path]
      render :action => path.to_s
    else
      no_route_matches path
    end
  end

  def stylesheet
    path = File.join(params[:path]) unless params[:path].nil?
    if stylesheet_exists? path
      render :template => File.join('stylesheets', path), :format => :css, :layout => false
    else
      no_route_matches path
    end
  end
  
protected
  
  def stylesheet_exists? path
    File.exists? File.join(STYLESHEETS_PATH, path)
  end
  
  def no_route_matches path
    raise ActionController::RoutingError, "No route matches
        <stylesheets/#{path.to_s}> with {:method => :get}".squish
  end
end
