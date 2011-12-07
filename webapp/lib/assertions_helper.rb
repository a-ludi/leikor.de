# -*- encoding : utf-8 -*-
module AssertionsHelper
  def assert_layout(layout, message=nil)
    clean_backtrace do
      rendered = @response.layout.to_s
      msg = build_message(message, "expecting layout <?> but rendering with <?>", layout, rendered)
      assert_block(msg) do
        if layout.nil?
          rendered.blank?
        else
          rendered.to_s.match(layout)
        end
      end
    end
  end
  
  def assert_errors_on(obj, options={})
    if options[:on].is_a? Symbol
      options[:message] = "expected errors on <#{obj}.#{options[:on]}>" unless options[:message]
      obj.valid?
      assert obj.errors.on(options[:on]), options[:message]
    else
      options[:message] = "expected errors on <#{obj}>" unless options[:message]
      assert ! obj.valid?, options[:message]
    end
  end
  
  def assert_creates_record_from(record_class, options={})
    message = "record of class #{record_class} could not be generated from #{options.inspect}"
    assert record_class.create(options).save, message
  end
  
  def assert_includes(collection, *objs)
    includes_all = true
    objs.each{|obj| includes_all &= collection.include? obj}
    message = "#{collection.inspect} does not include all of #{objs.inspect}"
    assert includes_all, message
  end
  
  def assert_exact_match(pattern, string, options={})
    options[:message] = "#{string} does not exactly match #{pattern}" unless options[:message]
    assert string =~ UtilityHelper::delimited(pattern), options[:message]
  end
  
  def assert_items_unique(collection, options={}, &proc)
    if block_given?
      collection = collection.map &proc
    end
    
    message = options[:message].to_s + (options[:message] ? '\n' : '')
    message += "#{collection.inspect} is empty"
    assert ! collection.empty?, message if options[:not_empty]
    
    message = options[:message].to_s + (options[:message] ? '\n' : '')
    message += "non-unique items in: #{collection.inspect}"
    assert_equal collection.length, collection.uniq.length, message
  end
  
  def assert_not_empty(collection, options={})
    options[:message] = "collection is empty" unless options[:message].blank?
    assert ! collection.empty?, options[:message]
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
  
  def assert_non_empty_kind_of(klass, object)
    assert_kind_of klass, object
    assert_not_empty object
  end

  def assert_logs(&proc)
    @controller.logger = MockLogger.new @controller.logger
    yield
    assert @controller.logger.logged?, "no message logged"
    @controller.logger = @controller.logger.original_logger
  end

private
  class MockLogger
    def initialize(logger)
      @original_logger = logger
    end
    
    def debug(*args); @logged = true; end
    alias :info :debug
    alias :warn :debug
    alias :error :debug
    alias :fatal :debug
    
    def logged?
      @logged or false
    end
    
    def original_logger; @original_logger; end
  end
  
  def assert_filter_applied(filter, action, options={})
    if action.nil?
      assert filter.options.empty?, options[:message]
    elsif filter.options.empty?
      assert ! options[:not], options[:message]
    elsif ! filter.options[:except].nil?
      assert options[:not] ^ ! filter.options[:except].include?(action.to_s), options[:message] + 'appers not in :except'
    elsif ! filter.options[:only].nil?
      assert options[:not] ^ filter.options[:only].include?(action.to_s), options[:message] + 'appers in :only'
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
