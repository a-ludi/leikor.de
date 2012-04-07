# -*- encoding: utf-8 -*-

class FairDatesController < ApplicationController
  after_filter :save_updated_at, :only => [:update, :create]
  before_filter :login_required, :except => [:index]
  
  def index
    @fair_dates = FairDate.find :all, :order => "from_date ASC, to_date ASC"
    @stylesheets = %w(fair_dates)
    @title = 'Messetermine'
  end
  
  def new
    @fair_date = FairDate.new do |fd|
      fd.from_date = Date.today
      fd.to_date = fd.from_date >> 1
    end
    @stylesheets = %w(message form fair_dates)
    @title = 'Neuer Messetermin'
    
    render :action => 'edit'
  end
  
  def create
    @fair_date = FairDate.create params[:fair_date]
    flash[:message] = {
      :title => 'Messetermin gespeichert',
      :text => "Der neue Messetermin „#{@fair_date.name}“ wurde erfolgreich gespeichert"}
    
    try_save_and_render_response
  end
  
  def edit
    @fair_date = FairDate.find params[:id]
    @stylesheets = %w(message form fair_dates)
    @title = 'Messetermin bearbeiten'
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
    if @fair_date.save
      @title ||= flash[:message][:title]
      @stylesheets = %w(fair_dates)
      redirect_to fair_dates_path
    else
      @stylesheets = %w(message form fair_dates)
      render :action => 'edit'
    end
  end
end
