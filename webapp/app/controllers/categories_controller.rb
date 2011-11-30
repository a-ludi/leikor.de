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
    create_sub_or_category_from_params
    @html_id = params[:html_id]
    if @category.save
      @partial = 'category'
    else
      @partial = 'form'
    end
    render :action => 'edit'
  end
  
  def edit
    @category = Category.find params[:id]
    @partial = params[:cancel] ? 'category' : 'form'
  end
  
  def update
    if update_sub_or_category_from_params
      @partial = 'category'
      flash[:saved_category_id] = @category.id
    else
      @partial = 'form'
    end
    render :action => 'edit'
  end
  
  def ask_destroy
    fetch_sub_or_category_from_params
    @stylesheets = ['message']
    @title = "#{@category.class.human_name} löschen?"
  end
  
  def destroy
    @category = Category.find params[:id]
    @category.destroy
    flash[:message] = {:text => "#{@category.class.human_name} „#{@category.name}“ wurde gelöscht."}
    
    redirect_to @category.class == Subcategory ?
      category_path(@category.category.url_hash) :
      categories_path
  end

private
  def set_random_html_id_or_take_from_param
    @html_id = params[:html_id] ? params[:html_id] : "new_category_#{Time.now.usec.to_s}"
  end
  
  def create_sub_or_category_from_params
    if_category = Proc.new {@category = Category.create params[:category]}
    if_subcategory = Proc.new {@category = Subcategory.create params[:subcategory]}
    do_for_sub_or_category if_category, if_subcategory
  end
  
  def update_sub_or_category_from_params
    if_category = Proc.new do
      @category = Category.find params[:id]
      @category.update_attributes params[:category]
    end
    if_subcategory = Proc.new do
      @category = Subcategory.find params[:id]
      @category.update_attributes params[:subcategory]
    end
    do_for_sub_or_category if_category, if_subcategory
  end
  
  def fetch_sub_or_category_from_params
    if_category = Proc.new {@category = Category.from_param params[:category]}
    if_subcategory = Proc.new {@category = Subcategory.from_param params[:subcategory]}
    do_for_sub_or_category if_category, if_subcategory
  end
  
  def do_for_sub_or_category(if_category, if_subcategory)
    if params[:category] and ! params[:subcategory]
      if_category.call
    elsif params[:subcategory]
      if_subcategory.call
    else
      raise ActionController::ActionControllerError, "parameter ':category' or ':subcategory' is missing"
    end
  end
end
