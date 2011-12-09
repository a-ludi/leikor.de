# -*- encoding: utf-8 -*-
class FairDatesController < ApplicationController
  after_filter :save_updated_at, :only => [:update]
  
  def index
    @fair_dates = FairDate.find :all, :order => "from_date ASC, to_date ASC"
    @stylesheets = ['static', 'fair_dates/index']
    @title = 'Messetermine'
  end
  
  def new
    @fair_date = FairDate.new do |fd|
      fd.from_date = Date.today
      fd.to_date = Date.today >> 1
    end
    @stylesheets = ['message']
    @title = 'Neuer Messetermin'
    @popup = params[:popup]
    
    render :action => 'edit', :layout => 'popup' if @popup
  end
  
  def create
    @fair_date = FairDate.create params[:fair_date]
    @stylesheets = ['message']
    @title = 'Neuer Messetermin'
    flash[:message] = {
      :title => 'Neuer Messetermin gespeichert',
      :text => "Der neue Messetermin „#{@fair_date.name}“ wurde erfolgreich gespeichert"}
    
    try_save_and_render_response
  end
  
  def edit
    @fair_date = FairDate.find params[:id]
    @stylesheets = ['message']
    @title = 'Messetermin bearbeiten'
    @popup = params[:popup]
    
    render :layout => 'popup' if @popup
  end
  
  def update
    @fair_date = FairDate.find params[:id]
    @fair_date.update_attributes params[:fair_date]
    flash[:message] = {
      :title => 'Änderungen am Messetermin gespeichert',
      :text => "Änderungen an „#{@fair_date.name}“ wurden erfolgreich gespeichert"}
    
    try_save_and_render_response
  end
  
  def destroy
    
  end
  
private
  
  def try_save_and_render_response(options={})
    @stylesheets = ['message']
    @popup = params[:fair_date][:popup]
    if @fair_date.save
      @title ||= flash[:message][:title]
      if @popup
        render :action => 'success', :layout => 'popup'
      else
        redirect_to fair_dates_url
      end
    else
      render :action => 'edit', :layout => @popup ? 'popup' : true
    end
  end
end
