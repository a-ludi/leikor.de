# -*- encoding : utf-8 -*-

class ArticlesController < ApplicationController
  before_filter :employee_required, :except => [:index]
  before_filter :fetch_categories, :only => [:index, :edit_order]
  before_filter :convert_prices_amount_to_numbers, :only => [:create, :update]
  after_filter :save_updated_at, :only => [:create, :update, :destroy, :reorder]
  
  def index
    @stylesheets = %w(category/browser article/index Markdown)
    @title = "#{@subcategory.name} (#{@category.name})"
    @scroll_target = 'content'
    
    render :layout => 'browser'
  end
  
  def new
    unless params[:cancel]
      @article = Article.new do |a|
        a.name = 'Neuer Artikel'
        a.description = 'Hier die Beschreibung einfügen …'
        a.article_number = generated_article_number
        a.subcategory_id = params[:subcategory].to_i
        a.ord = 0
      end
    else
      @cancel = true
      @html_id = params[:html_id]
    end
  end
  
  def edit_order
    @stylesheets = %w(category/browser article/edit_order)
    @title = "#{@subcategory.name} umsortieren"
    
    render :layout => 'browser'
  end
  
  def create
    params[:article][:subcategory] = Subcategory.find params[:article][:subcategory_id]
    params[:article][:ord] = params[:article][:subcategory].next_article_ord
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
    
    if @article.update_attributes params[:article]
      @article.reload
      @partial = 'article'
      flash[:saved_article_id] = @article.id
    else
      @partial = 'form'
    end
    render :action => 'edit'
  end
  
  def ask_destroy
    @stylesheets = %w(message)
    @title = "Artikel löschen?"
    @article = Article.find_by_article_number params[:article]
  end
  
  def destroy
    @article = Article.find params[:id]
    @article.destroy
    flash[:message].success "Artikel „#{@article.name}“ wurde gelöscht."
    
    redirect_to subcategory_url(@article.subcategory.url_hash)
  end
  
  def reorder
    errors = false
    new_order = params[:articles_list]
    new_order.each_index do |ord|
      id = new_order[ord].to_i
      article = Article.find id
      article.ord = ord
      errors |= ! article.save
    end
    
    unless errors
      flash[:message].success "Reihenfolge aktualisiert."
    else
      flash[:message].error "Speichern der neuen Reihenfolge ist fehlgeschlagen."
    end
    
    render :partial => 'layouts/push_message'
  end

protected

  def generated_article_number
    ('%06i' % Time.now.usec)[0...6].insert(-2, '.')
  end
  
  def convert_prices_amount_to_numbers
    prices = (params[:article][:prices_attributes] || {})
    prices.map do |key, price|
      unless price[:amount].nil?
        params[:article][:prices_attributes][key][:amount] =
            BigDecimal.from_s(price[:amount], :locale => :de)
      end
    end
  end
end
