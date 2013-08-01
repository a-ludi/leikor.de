# -*- encoding: utf-8 -*-

class FairDatesController < ApplicationController
  after_filter :save_updated_at, :only => [:update, :create, :destroy]
  before_filter :employee_required, :except => [:index]

  def index
    @fair_dates = FairDate.all
    @stylesheets = %w(fair_dates Markdown)
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
    @stylesheets = %w(message)

    flash[:message].success "Der neue Messetermin „#{@fair_date.name}“ wurde erfolgreich
        gespeichert".squish

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

    flash[:message].success "Änderungen an „#{@fair_date.name}“ wurden erfolgreich gespeichert"

    try_save_and_render_response
  end

  def destroy
    @fair_date = FairDate.find params[:id]
    @fair_date.destroy

    flash[:message].success "Messetermin „#{@fair_date.name}“ wurde gelöscht."
    flash.keep

    redirect_to fair_dates_path
  end

protected

  def try_save_and_render_response(options={})
    if @fair_date.save
      flash.keep

      redirect_to fair_dates_path
    else
      @stylesheets = %w(message form fair_dates)
      flash[:message].clear!

      render :action => 'edit'
    end
  end
end
