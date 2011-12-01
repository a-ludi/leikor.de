class PictureController < ApplicationController
  before_filter :login_required, :except => [:show]
  after_filter :save_updated_at, :only => [:update, :destroy]
  
  def show
    @article = Article.find params[:article_id]
    
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
    if params[:popup]
      flash[:popup] = true
      render :layout => 'popup'
    else
      flash[:popup] = false
    end
  end

  def update
    @article = Article.find params[:article_id]
    @article.picture = params[:article][:picture]
    try_save_and_render_response :success => "Bild für „#{@article.name}“ wurde gespeichert."
  end

  def destroy
    @article = Article.find params[:article_id]
    @article.picture.clear
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
        if flash[:popup]
          render :action => 'success', :layout => 'popup'
        else
          redirect_to subcategory_url(@article.subcategory.url_hash)
        end
      when :failure
        flash.keep :popup
        render :action => 'edit', :layout => flash[:popup] ? 'popup' : true
      else
        raise StandardError, 'internal error: state <#{state.inspect}> is unknown'
    end
  end
end
