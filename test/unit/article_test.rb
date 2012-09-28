# -*- encoding : utf-8 -*-
require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test_tested_files_checksum 'b86abcf7867b92c909b248caae8f6705'
  
  def setup
    @article = articles(:one)
  end

  test "default_scope" do
    assert_equal articles(:one, :five, :four, :three, :two), Article.all
  end
  
  test "should have many colors" do
    assert_present @article.colors
  end
  
  test "colors are only added once" do
    assert_equal @article.colors, @article.colors << colors(:red)
  end
  
  test "unused colors are deleted" do
    @color = Color.create(:label => 'new_color', :hex => '#123456')
    @article.colors << @color
    assert_includes @article.colors, @color
    
    @article.colors.delete @color
    
    refute Color.exists?(@color.id), 'unused color was not deleted'
  end
  
  test "prices should be dependent" do
    @article.destroy
    @article.prices.each do |price|
      assert price.destroyed?, '#{price.inspect} should be destroy'
    end
  end
  
  test "should have at least one price" do
    refute_errors_on @article, :on => :prices
    @article.prices.clear
    assert_errors_on @article, :on => :prices
  end
  
  test "should have a name" do
    @article.name = ''
    assert_errors_on @article, :on => :name
  end
  
  test "should have a article number" do
    @article.article_number = ''
    assert_errors_on @article, :on => :article_number
  end
  
  test "should have a subcategory" do
    @article.subcategory = nil
    assert_errors_on @article, :on => :subcategory
  end
  
  test "should have a numeric ord" do
    should_be_numeric :ord
  end
  
  test "should have a ord greater than or equal to 0" do
    should_be_greater_than_or_equal_to :ord, 0
  end
  
  test "should have a integer ord" do
    refute_errors_on @article, :on => :ord
    @article.ord = 1.5
    assert_errors_on @article, :on => :ord
  end
  
  test "width can be nil" do
    can_be_nil :width
  end
  
  test "should have a numeric width" do
    should_be_numeric :width
  end
  
  test "should have a positive width" do
    should_be_greater_than :width, 0.0
  end
  
  test "height can be nil" do
    can_be_nil :height
  end
  
  test "should have a numeric height" do
    should_be_numeric :height
  end
  
  test "should have a positive height" do
    should_be_greater_than :height, 0.0
  end
  
  test "depth can be nil" do
    can_be_nil :depth
  end
  
  test "should have a numeric depth" do
    should_be_numeric :depth
  end
  
  test "should have a positive depth" do
    should_be_greater_than :depth, 0.0
  end
  
  test "should have a unit if width, height or depth is present" do
    refute_errors_on @article, :on => :unit
    @article.unit = nil
    assert_errors_on @article, :on => :unit
    refute_errors_on articles(:five), :on => :unit
  end

  test "should have a known unit" do
    Article::UNITS.each do |unit|
      @article.unit = unit
      refute_errors_on @article, :on => :unit
    end
    
    @article.unit = 'Unknown'
    assert_errors_on @article, :on => :unit
  end
  
  test "should have a unique article number" do
    @article.article_number = articles(:two).article_number
    assert_errors_on @article, :on => :article_number
  end
  
  test "should have a well-formatted article number" do
    for mf_number in ['123456.1', '12345.123', 'a2345.1', '1234.12', '12345,1']
      @article.article_number = mf_number
      assert_errors_on @article, :on => :article_number, :message => "article number #{mf_number} is invalid"
    end
  end
  
  test "should return default picture url" do
    assert_equal '/images/picture/original/dummy.png', @article.picture.url
  end
  
  test "html_id returns string" do
    assert_kind_of String, @article.html_id
  end
  
  test "html ids are unique" do
    assert_items_unique Article.find(:all), :not_empty => true do |a|
      a.html_id
    end
  end
  
  test "url_hash includes neccessary fields" do
  	[:category, :subcategory, :article].each do |field|
    	assert_includes @article.url_hash, field
    end
  end
  
  test "url_hash includes correct values" do
    assert_equal(Hash[:category => @article.subcategory.category.to_param,
      :subcategory => @article.subcategory.to_param, :article => @article.article_number],
      @article.url_hash)
  end
  
  test "url_hash propagates custom options" do
    url_hash = @article.url_hash(:custom_key => :custom_value)
    assert_includes url_hash, :custom_key
    assert_equal :custom_value, url_hash[:custom_key]
  end
  
  test "description should be marked up with maruku" do
    assert_equal @article.description,
      "<p>This <em>is a</em> <strong>marked up</strong> description!</p>"
  end

private
  
  def should_be_numeric field
    @article.send "#{field.to_s}=".to_sym, 'Five Dollars Fiveteen'
    assert_errors_on @article, :on => field.to_sym
  end
  
  def should_be_greater_than field, value
    @article.send "#{field.to_s}=".to_sym, value
    assert_errors_on @article, :on => field.to_sym
    
    @article.send "#{field.to_s}=".to_sym, (value - 1.0)
    assert_errors_on @article, :on => field.to_sym
  end
  
  def should_be_greater_than_or_equal_to field, value
    @article.send "#{field.to_s}=".to_sym, value
    refute_errors_on @article, :on => field.to_sym
    
    @article.send "#{field.to_s}=".to_sym, (value - 1.0)
    assert_errors_on @article, :on => field.to_sym
  end
  
  def can_be_nil field
    @article.send "#{field.to_s}=".to_sym, nil
    refute_errors_on @article, :on => field.to_sym
  end
end
