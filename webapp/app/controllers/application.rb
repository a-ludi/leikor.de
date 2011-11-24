include ActionController::Translation
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '17d1fe39ecf394810dac8720303d7e9d'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password
  
  before_filter :fetch_logged_in_user, :fetch_updated_at
  LAST_UPDATED_TIME_FORMAT = '%H:%M Uhr %d.%m.%Y'
  
  def save_updated_at
    AppData['updated_at'] = Time.now
  end
  
  def fetch_updated_at
    @updated_at = AppData['updated_at']
  end
  helper_method :load_last_updated
  
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
  
  def fetch_categories(category_id=nil)
    @categories = Category.find(
      :all,
      :conditions => {:type => nil},
      :order => 'name ASC')
    
    unless category_id.nil?
      category = Category.from_param category_id
      unless category.is_a? Subcategory
        @category = category
      else
        @subcategory = category
        @category = @subcategory.category
      end
    end
  end
  
  def render_to_nested_layout(options={})
    options[:outer_layout] = 'application' if options[:outer_layout].nil?
    
    options[:text] = render_to_string options
    options[:layout] = options[:outer_layout]
    render options
  end
end
