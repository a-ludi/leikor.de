# -*- encoding : utf-8 -*-
module AssertionsHelper
  include AssertionsHelper::ActiveRecordAssertions
  include AssertionsHelper::FilterAssertions
  include AssertionsHelper::LoggerAssertions
  
  def refute_blank(object, message=nil)
    #TODO equivalent to assert_present
    refute object.blank?, (message || "expected non-blank object")
  end
  
  def assert_layout(layout, message=nil)
    clean_backtrace do
      rendered = @response.layout.to_s
      msg = build_message(message, "expecting layout <?> but rendering with <?>", layout, rendered)
      assert_block(msg) do
        unless layout
          rendered.blank?
        else
          rendered.match layout.to_s
        end
      end
    end
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
    #TODO equivalent to refute_empty
    options[:message] = "collection is empty" if options[:message].blank?
    assert ! collection.empty?, options[:message]
  end
  
  def assert_non_empty_kind_of(klass, object)
    #TODO replace ocurrences with assert_present
    assert_kind_of klass, object
    assert_not_empty object
  end
end
