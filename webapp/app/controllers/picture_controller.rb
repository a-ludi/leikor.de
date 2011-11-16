class PictureController < ApplicationController
  before_filter :login_required, :except => [:show]
  
  def show
    @article = Article.find params[:article_id]
    flash[:no_animations] = params[:no_animations]
    
    respond_to do |format|
      format.html do
        render(
          :partial => 'viewer',
          :layout => 'popup',
          :locals => {:article => @article})
      end
      format.js
    end
  end

  def edit
    @article = Article.find params[:article_id]
    @stylesheets = ['message']
    unless params[:popup].blank?
      flash[:popup] = true
      render :action => 'edit', :layout => 'popup'
    else
      flash[:popup] = false
      render :action => 'edit'
    end
  end

  def update
    @article = Article.find params[:article_id]
    @article.picture = params[:article][:picture]
    try_save_and_render_response(
      @article,
      :success => "Bild für „#{@article.name}“ wurde gespeichert."
    ) and return
  end

  def destroy
    @article = Article.find params[:article_id]
    @article.picture = nil
    try_save_and_render_response(
      @article,
      :success => "Bild für „#{@article.name}“ wurde gelöscht."
    ) and return
  end
  
private
  
  def try_save_and_render_response(article, options={})
    @stylesheets = ['message']
    if article.save
      flash[:message] = {:class => 'success', :text => options[:success]} unless options[:success].blank?
      if flash[:popup]
        render :action => 'success', :layout => 'popup'
      else
        redirect_to subcategory_url(article.subcategory.url_hash)
      end
    else
      flash[:errors_occurred] = true
      article.errors.clear and article.errors.add(
        :picture, Article::PICTURE_INVALID_MESSAGE)
      flash.keep :popup
      render :action => 'edit', :layout => flash[:popup] ? 'popup' : true
    end
  end
end
