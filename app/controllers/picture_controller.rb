# -*- encoding : utf-8 -*-
class PictureController < ApplicationController
  include Paperclip::Storage::Database::ControllerClassMethods
  
  before_filter :login_required, :except => [:show, :pictures]
  after_filter :save_updated_at, :only => [:update, :destroy]
  downloads_files_for :article, :picture, :file_name => :name
  
  def show
    @article = Article.find params[:article_id]
    @title = "Bild von „#{@article.name}“"
    
    respond_to do |format|
      format.html do
        render(
          :partial => 'viewer',
          :layout => 'popup',
          :locals => {:article => @article})
      end
      format.js do
        flash[:no_animations] = params[:no_animations]
      end
    end
  end

  def edit
    @article = Article.find params[:article_id]
    @stylesheets = ['message']
    @title = "Bild von „#{@article.name}“ bearbeiten"
    @popup = params[:popup]
    render :layout => 'popup' if @popup
  end

  def update
    @article = Article.find params[:article_id]
    @article.picture = params[:article][:picture]
    @popup = params[:popup]
    try_save_and_render_response :success => "Bild für „#{@article.name}“ wurde gespeichert."
  end

  def destroy
    @article = Article.find params[:article_id]
    @article.picture.clear
    @popup = params[:popup]
    try_save_and_render_response :success => "Bild für „#{@article.name}“ wurde gelöscht."
  end
  
private
  
  def try_save_and_render_response(options={})
    @stylesheets = ['message']
    if @article.save
      flash[:message] = {:class => 'success', :text => options[:success]} unless options[:success].blank?
      render_response :success
    else
      @article.errors.clear and @article.errors.add(
        :picture, Article::PICTURE_INVALID_MESSAGE)
      render_response :failure
    end
  end
  
  def render_response(state=:success)
    case state
      when :success
        @title ||= flash[:message][:text]
        if @popup
          render :action => 'success', :layout => 'popup'
        else
          redirect_to subcategory_url(@article.subcategory.url_hash)
        end
      when :failure
        render :action => 'edit', :layout => @popup ? 'popup' : true
      else
        raise StandardError, 'internal error: state <#{state.inspect}> is unknown'
    end
  end
end
