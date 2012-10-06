# -*- encdoing : utf-8 -*-
require 'test_helper'

class FairDatesControllerTest < ActionController::TestCase
  test "new create edit update destroy actions should require employee" do
    [:new, :create, :edit, :update, :destroy].each do |action|
      assert_before_filter_applied :employee_required, action
    end
  end
  
  test "index action should not require employee" do
    assert_before_filter_not_applied :employee_required, :index
  end
  
  test "create update destroy actions should save updated_at" do
    [:create, :update, :destroy].each do |action|
      assert_after_filter_applied :save_updated_at, action
    end
  end
  
  test "index action" do
    get :index
    
    assert_equal fair_dates(:one, :two, :three), assigns(:fair_dates)
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
  end
  
  test "new action" do
    https!
    get :new, {}, with_user
    
    assert_kind_of FairDate, assigns(:fair_date)
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
    assert_template :edit
  end
  
  test "create action" do
    create_fair_date
    
    assert_kind_of FairDate, assigns(:fair_date)
    assert_respond_to assigns(:stylesheets), :each
    refute_empty flash[:message]
    assert_redirected_to fair_dates_path
  end
  
  test "create action fails" do
    create_fair_date :with => :errors
    
    assert_respond_to assigns(:stylesheets), :each
    assert_empty flash[:message]
    assert_template 'edit'
  end
  
  test "edit action" do
    https!
    get :edit, {:id => fair_dates(:one).id} , with_user
    
    assert_equal assigns(:fair_date), fair_dates(:one)
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
  end
  
  test "update action" do
    update_fair_date
    
    assert_equal @fair_date[:name], assigns(:fair_date).name
    refute_empty flash[:message]
    assert_redirected_to fair_dates_path
  end

  test "update action fails" do
    update_fair_date :with => :errors
    
    assert_respond_to assigns(:stylesheets), :each
    assert_empty flash[:message]
    assert_template 'edit'
  end
  
  test "destroy action" do
    https!
    @fair_date = fair_dates(:one)
    delete :destroy, {:id => @fair_date.to_param}, with_user
    
    assert_nil FairDate.find_by_id(@fair_date.id)
    refute_empty flash[:message]
    assert_redirected_to fair_dates_path
  end
  
protected
  
  def create_fair_date options={}
    @fair_date = {
        :from_date => '2011-11-11',
        :to_date => '2012-12-12',
        :name => 'Messename',
        :homepage => 'http://www.example.com/',
        :stand => 'Test-Stand',
        :comment => 'Test **Kommentar**'}
    
    if options.include? :with and options[:with] == :errors
      @fair_date[:name] = ''
    end
    
    params = {:fair_date => @fair_date}
    
    https!
    post :create, params, with_user
  end
  
  def update_fair_date options={}
    @fair_date = {
        :from_date => '2011-11-11',
        :to_date => '2012-12-12',
        :name => 'Messename',
        :homepage => 'http://www.example.com/',
        :stand => 'Test-Stand',
        :comment => 'Test **Kommentar**'}
    
    if options.include? :with and options[:with] == :errors
      @fair_date[:name] = ''
    end
    
    params = {:fair_date => @fair_date, :id => fair_dates(:one).id}
    
    https!
    put :update, params, with_user
  end
end
