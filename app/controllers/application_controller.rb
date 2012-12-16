# -*- encoding : utf-8 -*-

class ApplicationController < ActionController::Base
  include ExceptionNotification::Notifiable
  
  helper :all # include all helpers, all the time
  helper_method :logged_in?
  protect_from_forgery
  filter_parameter_logging :password, :primary_email_address, :external_id

  before_filter :fetch_current_user, :fetch_updated_at, :prepare_flash_message
  unless Rails.env.production?
    after_filter :log_if_title_not_set, :except => [:stylesheet, :pictures]
  end  
  
  if Rails.env.test?
    def test_method
      unless flash.include? :block
        @result = self.send params[:method].to_sym, *flash[:params]
      else
        @result = self.send params[:method].to_sym, *flash[:params], &flash[:block]
      end
      
      render :inline => params[:render].to_s, :layout => false  if params[:render] != false
    end
    
    def set_title
      @title = params[:title] || 'This is a test case'
      
      render :inline => '', :layout => false
    end
  end
  
protected

  unless Rails.env.development?
    include SslRequirement

    alias orig_ssl_required? ssl_required?
    def ssl_required?
      logged_in? or orig_ssl_required?
    end
  else
    include MockSslRequirement
  end
  
  def save_updated_at
    AppData['updated_at'] = Time.now.getutc
  end
  
  def fetch_updated_at
    @updated_at = AppData['updated_at'] || Time::mktime(2011, 11, 11, 11, 11,
        11, 111)
    @updated_at = @updated_at.localtime("+01:00")
  end
  
  def prepare_flash_message
    flash[:message] = FlashMessage.new  unless flash.include? :message
  end
  
  def login_user!(user)
    session[:user_id] = user.id
    session[:login] = user.login
    
    fetch_current_user
  end
  
  def logout_user!
    session[:user_id] = @current_user = nil
  end
  
  def logged_in?(class_or_user=User)
    class_or_user === @current_user
  end
  
  def fetch_current_user
    @current_user = User.find_by_id(session[:user_id])
  end

  def user_required
    logged_in? or set_up_user_required_message
  end
  
  def employee_required
    logged_in? Employee or set_up_user_required_message 'Dazu haben Sie keine Erlaubnis.'
  end
  
  def fetch_categories
    @categories = Category.is_a_category
    
    if params[:subcategory]
      @subcategory = Subcategory.from_param params[:subcategory]
      @category = @subcategory.category
    elsif params[:category]
      @category = Category.from_param params[:category]
    end
    
    return true
  end
  
  def not_found(message=nil, options={})
    options = {:log => false}.merge options
    logger.warn message if options[:log]
    raise ActionController::RoutingError.new(message || 'Not found')
  end

  def render_to_nested_layout(options={})
    logger.error "[error] method render_to_nested_layout is deprecated"
    options[:outer_layout] = 'application' if options[:outer_layout].nil?
    
    options[:text] = render_to_string options
    options[:layout] = options[:outer_layout]
    render options
  end
  
  def self.ssl_required_by_all_actions
    class_eval{ def ssl_required?; true; end }
  end
  
  def log_if_title_not_set
    if @title.nil? and not params[:welcome]
      logger.warn "[warning] action <#{action_name}> in controller
          <#{controller_name}> does not set @title".squish
    end
    
    return true
  end

  def escape_like_pattern pattern
    pattern.gsub('%', '\\%').gsub('_', '\\_')
  end
  helper_method :escape_like_pattern

private

  #TODO user translation for message
  def set_up_user_required_message(message='Bitte melden Sie sich an.')
    flash[:referer] = request.path  if flash[:referer].blank?
    flash[:message].error message
    respond_to do |format|
      format.html { redirect_to new_session_path }
      format.js { render :partial => 'layouts/push_message' }
    end
    
    return false
  end
end
