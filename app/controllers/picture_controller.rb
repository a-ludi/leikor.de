# -*- encoding : utf-8 -*-
class PictureController < ApplicationController
  include Paperclip::Storage::Database::ControllerClassMethods
  ssl_allowed :pictures

  before_filter :employee_required, :except => [:show, :pictures]
  after_filter :save_updated_at, :only => [:update, :destroy]
  after_filter :update_picture_dimensions, :only => [:update, :destroy]
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

    if params.include? :article
      params[:article].delete :picture_height
      params[:article].delete :picture_width
      @article.picture = params[:article][:picture]
      try_save_and_render_response :success => "Bild für „#{@article.name}“ wurde gespeichert."
    else
      try_save_and_render_response :failure
    end
  end

  def destroy
    @article = Article.find params[:article_id]
    @article.picture.clear
    try_save_and_render_response :success => "Bild für „#{@article.name}“ wurde gelöscht."
  end

private

  def try_save_and_render_response(options={})
    @popup = params[:popup]
    @stylesheets = ['message']
    if options != :failure and @article.save
      flash[:message].success options[:success] unless options[:success].blank?
      render_response :success
    else
      logger.debug "[PictureController] errors on article: <#{@article.errors.inspect}>"
      @article.errors.clear and @article.errors.add(
        :picture, Article::PICTURE_INVALID_MESSAGE)
      self.class.skip_after_filter :update_picture_dimensions
      render_response :failure
    end
  end

  def render_response(state=:success)
    case state
      when :success
        @title ||= flash[:message].text
        if @popup
          render :action => 'success', :layout => 'popup'
        else
          redirect_to subcategory_url(@article.subcategory.url_hash)
        end
      when :failure
        @stylesheets = ['message']
        @title = "Bild von „#{@article.name}“ bearbeiten"
        render :action => 'edit', :layout => @popup ? 'popup' : true
      else
        raise StandardError, 'internal error: state <#{state.inspect}> is unknown'
    end
  end

  def update_picture_dimensions
    if @article.picture?
      geom = Paperclip::Geometry.from_file @article.picture.to_file
      @article.picture_width, @article.picture_height = geom.width, geom.height
    else
      @article.picture_width, @article.picture_height = 600, 600
    end
    @article.save
  end
end
