class CategoriesController < ApplicationController
  before_filter :login_required, :except => [:index, :subindex]
  before_filter :fetch_categories, :only => [:index, :subindex]
  after_filter :save_updated_at, :only => [:create, :update, :destroy]

  def index
    @stylesheets = ['category/browser', 'category/index']
    @title = 'Sortiment'
    
    render_to_nested_layout :layout => 'browser'
  end
  
  def subindex
    @stylesheets = ['category/browser', 'category/index']
    @title = @category.name
    
    render_to_nested_layout :layout => 'browser'
  end
  
  def new
    @category = params[:category_id] ?
      Subcategory.new(:category => Category.find(params[:category_id])) :
      Category.new
    @category.name = "Neue #{@category.class.human_name}"
    set_random_html_id_or_take_from_param
    @cancel = true unless params[:cancel].blank?
  end
  
  def create
    if params[:category]
      @category = Category.create params[:category]
    else
      @category = Subcategory.create params[:subcategory]
    end
    @html_id = params[:html_id]
    if @category.save
      @partial = 'category'
    else
      flash[:errors_occurred] = true
      @partial = 'form'
    end
    render :action => 'edit'
  end
  
  def edit
    @category = Category.find params[:id]
    @partial = params[:cancel] ? 'category' : 'form'
  end
  
  def update
    if params[:category]
      @category = Category.find params[:id]
      @category.name = params[:category][:name]
    else
      @category = Subcategory.find params[:id]
      @category.name = params[:subcategory][:name]
    end
    
    if @category.save
      @partial = 'category'
      flash[:saved_category_id] = @category.id
    else
      flash[:errors_occurred] = true
      @partial = 'form'
    end
    render :action => 'edit'
  end
  
  def ask_destroy
    if params[:category]
      @category = Category.from_param params[:category]
    else
      @category = Subcategory.from_param params[:subcategory]
    end
    @stylesheets = ['message']
    @title = "#{@category.class.human_name} löschen?"
  end
  
  def destroy
    @category = Category.find params[:id]
    @category.destroy
    flash[:message] = {:text => "#{@category.class.human_name} „#{@category.name}“ wurde gelöscht."}
    
    redirect_to @category.is_a?(Subcategory) ?
      category_path(@category.category.url_hash) :
      categories_path
  end

private
  def set_random_html_id_or_take_from_param
    @html_id = params[:html_id] ? params[:html_id] : "new_category_#{Time.now.usec.to_s}"
  end
end
