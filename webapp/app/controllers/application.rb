include ActionController::Translation

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # :secret => '17d1fe39ecf394810dac8720303d7e9d'
  filter_parameter_logging :password

  before_filter :fetch_logged_in_user, :fetch_updated_at
  
  def save_updated_at
    AppData['updated_at'] = Time.now
  end
  
  def fetch_updated_at
    @updated_at = AppData['updated_at'] || Time::mktime(2011, 11, 11, 11, 11, 11, 111)
  end
  
  def fetch_logged_in_user
    return if @current_user = User.find_by_id(session[:user_id])
    @current_user = nil
  end
  
  def user_logged_in?
    not @current_user.nil?
  end
  alias :superuser_logged_in? :user_logged_in?
  helper_method :user_logged_in?, :superuser_logged_in?
  
  def login_required
    return true if user_logged_in?
    flash[:referer] = request.referer if flash[:referer].blank?
    flash[:message] = {
      :class => 'error',
      :text => 'Dafür müssen Sie angemeldet sein.'}
    respond_to do |format|
      format.html { redirect_to new_session_path }
      format.js { render :partial => 'layouts/push_message' }
    end
    
    return false
  end
  
  def fetch_categories
    @categories = Category.find(:all, :conditions => {:type => nil}, :order => 'name ASC')
    
    if params[:category] and not params[:subcategory]
      @category = Category.from_param params[:category]
    elsif params[:subcategory]
      @subcategory = Subcategory.from_param params[:subcategory]
      @category = @subcategory.category
    end
    
    return true
  end
  
  def render_to_nested_layout(options={})
    options[:outer_layout] = 'application' if options[:outer_layout].nil?
    
    options[:text] = render_to_string options
    options[:layout] = options[:outer_layout]
    render options
  end
  
  def md5sum(str)
    include Digest
    Digest::MD5.new.update(str).to_s
  end
end
