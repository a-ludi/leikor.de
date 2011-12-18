# -*- encoding : utf-8 -*-
class ArticlesController < ApplicationController
  before_filter :login_required, :except => [:index]
  before_filter :fetch_categories, :only => [:index]
  after_filter :save_updated_at, :only => [:create, :update, :destroy]
  
  def index
    @stylesheets = ['category/browser', 'article/index']
    @title = "#{@subcategory.name} (#{@category.name})"
    
    render_to_nested_layout :layout => 'browser'
  end
  
  def new
    unless params[:cancel]
      @article = Article.new do |a|
        a.name = 'Neuer Artikel'
        a.description = 'Hier die Beschreibung einfügen …'
        a.price = 0.99
        a.article_number = generated_article_number
        a.subcategory_id = params[:subcategory].to_i
      end
    else
      @cancel = true
      @html_id = params[:html_id]
    end
  end
  
  def create
    params[:article][:price] = get_price_from_param params[:article][:price]
    params[:article][:subcategory] = Subcategory.find params[:article][:subcategory_id]
    @article = Article.create params[:article]
    if @article.save
      @partial = 'article'
      flash[:html_id] = params[:html_id]
    else
      @partial = 'form'
    end
    render :action => 'edit'
  end
  
  def edit
    @article = Article.find params[:id]
    @partial = params[:cancel] ? 'article' : 'form'
  end
  
  def update
    @article = Article.find params[:id]
    flash[:html_id] = params[:html_id]
    params[:article][:price] = get_price_from_param params[:article][:price]
    
    if @article.update_attributes params[:article]
      @partial = 'article'
      flash[:saved_article_id] = @article.id
    else
      @partial = 'form'
    end
    render :action => 'edit'
  end
  
  def ask_destroy
    @stylesheets = ['message']
    @title = "Artikel löschen?"
    @article = Article.find_by_article_number params[:article]
  end
  
  def destroy
    @article = Article.find params[:id]
    @article.destroy
    flash[:message] = {:text => "Artikel „#{@article.name}“ wurde gelöscht."}
    
    redirect_to subcategory_url(@article.subcategory.url_hash)
  end
  
private

  def generated_article_number
    ('%06i' % Time.now.usec)[0...6].insert(-2, '.')
  end
  
  def get_price_from_param(price)
    (price.sub ',', '.').to_f
  end
end
