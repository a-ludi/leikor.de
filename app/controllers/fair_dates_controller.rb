# -*- encoding: utf-8 -*-
class FairDatesController < ApplicationController
  after_filter :save_updated_at, :only => [:update]
  
  def index
    @fair_dates = FairDate.find :all, :order => "from_date ASC, to_date ASC"
    @stylesheets = ['static', 'fair_dates/index']
    @title = 'Messetermine'
    flash[:message] = {
      :title => 'Messetermin gespeichert',
      :text => "Der neue Messetermin wurde erfolgreich gespeichert",
      :class => 'error'}
  end
  
  def new
    @fair_date = FairDate.new do |fd|
      fd.from_date = Date.today
      fd.to_date = fd.from_date >> 1
    end
    @stylesheets = ['message', 'fair_dates/edit']
    @title = 'Neuer Messetermin'
    @popup = params[:popup]
    
    render :action => 'edit', :layout => (@popup ? 'popup' : true)
  end
  
  def create
    @fair_date = FairDate.create params[:fair_date]
    @stylesheets = ['message']
    flash[:message] = {
      :title => 'Messetermin gespeichert',
      :text => "Der neue Messetermin „#{@fair_date.name}“ wurde erfolgreich gespeichert"}
    
    try_save_and_render_response
  end
  
  def edit
    @fair_date = FairDate.find params[:id]
    @stylesheets = ['message', 'fair_dates/edit']
    @title = 'Messetermin bearbeiten'
    @popup = params[:popup]
    
    render :layout => 'popup' if @popup
  end
  
  def update
    @fair_date = FairDate.find params[:id]
    @fair_date.update_attributes params[:fair_date]
    flash[:message] = {
      :title => 'Messetermin gespeichert',
      :text => "Änderungen an „#{@fair_date.name}“ wurden erfolgreich gespeichert"}
    
    try_save_and_render_response
  end
  
  def destroy
    @fair_date = FairDate.find params[:id]
    @fair_date.destroy
    flash[:message] = {:text => "Messetermin „#{@fair_date.name}“ wurde gelöscht."}
    
    redirect_to fair_dates_path
  end
  
private
  
  def try_save_and_render_response(options={})
    @stylesheets = ['message']
    @popup = params[:popup]
    if @fair_date.save
      @title ||= flash[:message][:title]
      if @popup
        render :action => 'success', :layout => 'popup'
      else
        redirect_to fair_dates_path
      end
    else
      @stylesheets << 'fair_dates/edit'
      render :action => 'edit', :layout => @popup ? 'popup' : true
    end
  end
end
