# -*- encoding : utf-8 -*-
class StaticController < ApplicationController
  caches_page :page, :stylesheet
  
  REGISTERED_PAGES = {
    :ueber_uns => {:name => 'Über uns', :stylesheets => ['static']},
    :kontakt => {:name => 'Kontakt', :stylesheets => ['message', 'static/kontakt']},
    :impressum => {:name => 'Impressum', :stylesheets => ['message', 'static', 'static/kontakt']},
    :AGB =>  {:name => 'AGB', :stylesheets => ['static', 'static/kontakt']},
    :'google068735b263445301.html' => {:name => 'Google Verification'}
  }
  REGISTERED_PAGES[:colors] = {:name => 'Farbpalette', :stylesheets => ['static']} if RAILS_ENV == 'development'
  
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
      raise ActionController::RoutingError, "No route matches <#{path.inspect}> with {:method => :get}"
    end
  end

  def stylesheet
    path = File.join(params[:path]) unless params[:path].nil?
    if stylesheet_exists? path
      render :template => File.join('stylesheets', path), :format => :css, :layout => false
    else
      raise ActionController::RoutingError, "No route matches <stylesheets/#{path.to_s}> with {:method => :get}"
    end
  end
  
private
  
  def stylesheet_exists? path
    File.exists? File.join(STYLESHEETS_PATH, path)
  end
end
