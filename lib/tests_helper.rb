# -*- encoding : utf-8 -*-

module TestsHelper
  def https!(state=true)
    if state
      @request.env['HTTPS'] = 'on'
    else
      @request.env['HTTPS'] = nil
    end
  end
  
  def with_employee(session={})
    with_user Employee.first
  end

  def with_customer(session={})
    with_user Customer.first
  end

  def with_user(user=:john, session={})
    user = users(user) if user.is_a? Symbol
    @user = user
    session.merge(:user_id => user.id)
  end

  def with_referer(referer='/from/here/on')    
    @request.env['HTTP_REFERER'] = @referer = referer
  end
  
  def call_method(method, params=[], options={})
    req_params = options[:params] || {}
    req_params.merge! :method => method, :render => options[:render]
    session = options[:session] || {}
    flash = options[:flash] || {}
    flash[:params] = params
    
    unless options[:xhr]
      get 'test_method', req_params, session, flash
    else
      xhr :get, 'test_method', req_params, session, flash
    end
    
    @result = assigns(:result)
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
    
  def mailer
    self.class.instance_variable_get :@mailer || ActionMailer::Base
  end
  
  module ClassMethods
    def tests_mailer mailer
      setup do
        mailer.deliveries.clear
        @mailer = mailer
      end
    end
  end
end
