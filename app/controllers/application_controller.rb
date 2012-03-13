# -*- encoding : utf-8 -*-
#include ActionController::Translation

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :logged_in?
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password

  before_filter :fetch_logged_in_user, :fetch_updated_at
  after_filter :log_if_title_not_set, :except => [:stylesheet, :pictures] unless RAILS_ENV == 'production'
  after_filter :prepare_flash_message

protected
  def save_updated_at
    AppData['updated_at'] = Time.now.getutc
  end
  
  def fetch_updated_at
    @updated_at = AppData['updated_at'] || Time::mktime(2011, 11, 11, 11, 11, 11, 111)
    @updated_at = @updated_at.localtime("+01:00")
  end
  
  def login_user!(user, message=nil)
    prepare_flash_message message
    session[:user_id] = user.id
    session[:login] = user.login
    
    fetch_logged_in_user
  end
  
  def logout_user!(message=nil)
    prepare_flash_message(message) if logged_in?
    
    session[:user_id] = @current_user = nil
  end
  
  def prepare_flash_message(message=nil)
    logger.debug "[debug] preparing flash message"
    
    return unless flash.include?(:message) or not message.nil?
    
    flash[:message] = message unless message.nil?
    flash[:message] = {:text => flash[:message]} if flash[:message].is_a? String
    flash[:message][:title] ||= case flash[:message][:class]
      when 'error' then 'Fehler'
      when 'success' then 'Erfolg'
      else 'Hinweis'
    end
    
    logger.debug "[debug] message = <#{message.inspect}>"
    logger.debug "[debug] flash[:message] = <#{flash[:message].inspect}>"
  end
  
  def fetch_logged_in_user
    return if @current_user = User.find_by_id(session[:user_id])
    @current_user = nil
  end
  
  def logged_in?(klass=User)
    not @current_user.nil? and @current_user.is_a? klass
  end
  
  def user_required
    return true if logged_in?
    
    flash[:referer] = request.referer if flash[:referer].blank?
    prepare_flash_message :class => 'error', :text => 'Bitte melden Sie sich an.'
    respond_to do |format|
      format.html { redirect_to new_session_path }
      format.js { render :partial => 'layouts/push_message' }
    end
    
    return false
  end
  
  def employee_required
    return true if logged_in? Employee
    
    prepare_flash_message :class => 'error', :text => 'Dazu haben Sie keine Erlaubnis.'
    respond_to do |format|
      format.html { redirect_to (request.referer || :root) }
      format.js { render :partial => 'layouts/push_message' }
    end
    
    return false
  end
  
  def fetch_categories
    @categories = Category.find(:all, :conditions => {:type => nil}, :order => 'ord ASC')
    
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
  
  def not_found(message, options={})
    options = {:log => false}.merge options
    logger.warn message if options[:log]
    raise ActionController::RoutingError.new(message || 'Not found')
  end
  
  def log_if_title_not_set
    if @title.nil? and not params[:welcome]
      logger.warn "[warning] action <#{action_name}> in controller <#{controller_name}> does not set @title"
    end
    
    return true
  end
end
