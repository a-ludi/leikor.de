# -*- encoding : utf-8 -*-

module TestsHelper
  def with_employee(session={})
    with_user Employee.first
  end

  def with_customer(session={})
    with_user Customer.first
  end

  def with_employee(session={})
    with_user :john
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
    def test_tested_files_checksum(files_with_checksum)
      if files_with_checksum.is_a? String
        expected_checksum = files_with_checksum
        
        basename = self.to_s[0..-5].underscore + '.rb'
        dirname = case self.to_s
          when /ControllerTest$/; %w(app controllers)
          when /HelperTest$/; %w(app helpers)
          else; %w(app models)
        end
        filename = File.join dirname + [basename]
        
        files_with_checksum = [[filename, expected_checksum]]
      end
      
      test "tested file did not change" do
        require 'digest/md5'
        files_with_checksum.each do |filename, expected_checksum|
          actual_checksum = Digest::MD5.file(filename).to_s
          assert_equal expected_checksum, actual_checksum, "checksum error on file <%s>" % filename
        end
      end
    end
    
    def tests_mailer mailer
      setup do
        mailer.deliveries.clear
        @mailer = mailer
      end
    end
  end
end
