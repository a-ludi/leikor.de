# -*- encoding : utf-8 -*-

class CategoriesController < ApplicationController
  before_filter :employee_required, :except => [:index, :subindex]
  before_filter :fetch_categories, :only => [:index, :subindex]
  after_filter :save_updated_at, :only => [:create, :update, :destroy, :reorder]

  def index
    @stylesheets = ['category/browser', 'category/index']
    @title = 'Sortiment'
    @scroll_target = 'categories'

    render :layout => 'browser'
  end

  def subindex
    @stylesheets = ['category/browser', 'category/index']
    @title = @category.name
    @scroll_target = 'categoryBrowser_' + @category.id.to_s

    render :layout => 'browser'
  end

  def new
    @category = params[:category_id] ?
      Subcategory.new(:category => Category.find(params[:category_id])) :
      Category.new
    @category.name = "Neue #{@category.class.human_name}"
    set_random_html_id_or_take_from_param
    @cancel = (not params[:cancel].blank?)
  end

  def create
    create_sub_or_category_from_params
    @html_id = params[:html_id]
    @partial = (@category.save ? 'category' : 'form')
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
    flash[:message].success "#{@category.class.human_name} „#{@category.name}“ wurde gelöscht."
    flash.keep

    redirect_to @category.class == Subcategory ?
      category_path(@category.category.url_hash) :
      categories_path
  end

  def reorder
    errors = false
    new_order = params[:categories_list] || params[:subcategories_list]
    new_order.each_index do |ord|
      id = new_order[ord].to_i
      category = Category.find id
      category.ord = ord
      errors |= ! category.save
    end

    unless errors
      flash[:message].success "Reihenfolge aktualisiert."
    else
      flash[:message].error "Speichern der neuen Reihenfolge ist fehlgeschlagen."
    end

    render :partial => 'layouts/push_message'
  end

protected

  def set_random_html_id_or_take_from_param
    @html_id = params[:html_id] ? params[:html_id] : "new_category_#{Time.now.usec.to_s}"
  end

  def create_sub_or_category_from_params
    if_category = Proc.new {
        @category = Category.create params[:category].merge(
            :ord => Category.next_ord)}

    if_subcategory = Proc.new {
        category = Category.find params[:subcategory][:category_id]
        @category = Subcategory.create params[:subcategory].merge(
            :ord => category.next_subcategory_ord)}

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
