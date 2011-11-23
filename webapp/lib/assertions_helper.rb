module AssertionsHelper
  def assert_errors_on(obj, options={})
    if options[:on].is_a? Symbol
      options[:message] = "expected errors on #{obj}.#{options[:on]}" unless options[:message]
      obj.valid?
      assert obj.errors.on(options[:on]), options[:message]
    else
      options[:message] = "expected errors on #{obj}" unless options[:message]
      assert ! obj.valid?, options[:message]
    end
  end
  
  def assert_creates_record_from(record_class, options={})
    message = "record of class #{record_class} could not be generated from #{options.inspect}"
    assert record_class.create(options).save, message
  end
  
  def assert_includes(obj, *keys)
    includes_all = true
    keys.each do |key|
      includes_all &= obj.include? key
    end
    message = "#{obj.inspect} does not include all of #{keys.inspect}"
    assert includes_all, message
  end
  
  def assert_exact_match(pattern, string, options={})
    options[:message] = "#{string} does not exactly match #{pattern}" unless options[:message]
    assert string =~ UtilityHelper::delimited(pattern), options[:message]
  end
  
  def assert_items_unique(collection, options={}, &proc)
    if block_given?
      collection.map! &proc
    end
  
    options[:message] = "#{collection} is empty" unless options[:message]
    assert ! collection.empty?, options[:message] if options[:not_empty]
    
    options[:message] = "non-unique items in: #{collection.inspect}" unless options[:message]
    assert_equal collection.length, collection.uniq.length, options[:message]
  end
  
  def assert_not_empty(collection, options={})
    options[:message] = "collection is empty" unless options[:message].blank?
    assert ! collection.empty?, options[:message]
  end
  
  def assert_before_filter_applied(filter_name, controller, action)
    filter = find_matching_before_filter(controller, filter_name)
    message = "no before filter set for '#{action}'; "
    if filter.options.empty?
      assert true
    elsif ! filter.options[:only].nil?
      assert filter.options[:only].include?(action.to_s), message + 'appers not in :only'
    elsif ! filter.options[:except].nil?
      assert ! filter.options[:except].include?(action.to_s), message + 'appers in :except'
    else
      flunk 'unkown state of options occured; please investigate'
    end
  end

  def assert_before_filter_not_applied(filter_name, controller, action)
    filter = find_matching_before_filter(controller, filter_name)
    message = "before filter set for '#{action}'"
    if filter.options.empty?
      flunk message
    elsif ! filter.options[:except].nil?
      assert filter.options[:except].include?(action.to_s), message + 'appers not in :except'
    elsif ! filter.options[:only].nil?
      assert !filter.options[:only].include?(action.to_s), message + 'appers in :only'
    else
      flunk 'unkown state of options occured; please investigate'
    end
  end

private
  def find_matching_before_filter(controller, filter_name)
    filters = controller.class.filter_chain()
    filters.each do |filter|
      return filter if filter.before? and filter == filter_name
    end unless filters.nil?
    return nil
  end
end
