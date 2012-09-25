# -*- encoding : utf-8 -*-
module AssertionsHelper::FilterAssertions
  def assert_skips_before_filter(filter_name)
    begin
      find_matching_before_filter filter_name
    rescue StandardError
      pass
    else
      flunk "before filter '#{filter_name}' not skipped"
    end
  end
  
  def assert_skips_after_filter(filter_name)
    begin
      find_matching_after_filter filter_name
    rescue StandardError
      pass
    else
      flunk "after filter '#{filter_name}' not skipped"
    end
  end
  
  def assert_before_filter_applied(filter_name, action=nil)
    filter = find_matching_before_filter filter_name
    assert_filter_applied filter, action, :message => "before filter '#{filter_name}' not set for '#{action or 'all actions'}'"
  end

  def assert_before_filter_not_applied(filter_name, action)
    filter = find_matching_before_filter filter_name
    assert_filter_applied filter, action, :message => "before filter '#{filter_name}' set for '#{action}'", :not => true
  end
  
  def assert_after_filter_applied(filter_name, action=nil)
    filter = find_matching_after_filter filter_name
    assert_filter_applied filter, action, :message => "after filter '#{filter_name}' not set for '#{action or 'all actions'}'"
  end

  def assert_after_filter_not_applied(filter_name, action)
    filter = find_matching_after_filter filter_name
    assert_filter_applied filter, action, :message => "after filter '#{filter_name}' set for '#{action}'", :not => true
  end

private
  
  def assert_filter_applied(filter, action, options={})
    if action.nil?
      assert filter.options.empty?, options[:message]
    elsif filter.options.empty?
      assert ! options[:not], options[:message]
    elsif ! filter.options[:except].nil?
      assert options[:not] ^ ! filter.options[:except].include?(action.to_s),
          options[:message] + 'appears not in :except'
    elsif ! filter.options[:only].nil?
      assert options[:not] ^ filter.options[:only].include?(action.to_s),
          options[:message] + 'appears in :only'
    else
      flunk 'unkown state of options occured; please investigate'
    end
  end
  
  def find_matching_before_filter(filter_name)
    on_error_specify_filter_type 'before_filter' do
      find_matching_filter(filter_name) {|filter| filter.before?}
    end
  end
  
  def find_matching_after_filter(filter_name)
    on_error_specify_filter_type 'after_filter' do
      find_matching_filter(filter_name) {|filter| filter.after?}
    end
  end
  
  def find_matching_filter(filter_name)
    filters = @controller.class.filter_chain()
    match_idx = filters.index do |filter|
      filter == filter_name && (yield filter)
    end unless filters.nil?
    unless match_idx.nil?
      filters[match_idx]
    else
      raise StandardError, "no filter named '#{filter_name}' in controller #{@controller.class}"
    end
  end
  
  def on_error_specify_filter_type(filter_type, &proc)
    begin
      yield
    rescue StandardError => e
      raise e, e.message.gsub(/\bfilter\b/, filter_type)
    end
  end
end
