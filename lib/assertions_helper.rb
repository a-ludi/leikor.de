# -*- encoding : utf-8 -*-
module AssertionsHelper
  include AssertionsHelper::ActionMailerAssertions
  include AssertionsHelper::ActiveRecordAssertions
  include AssertionsHelper::FilterAssertions
  include AssertionsHelper::LoggerAssertions
  
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
  
  def assert_stylesheets_and_title
    assert_respond_to assigns(:stylesheets), :each
    assert_present assigns(:title)
  end
  
  def assert_https
    assert https?, "expected a secure HTTPS request"
  end
  
  def refute_https
    refute https?, "expected an insecure HTTP request"
  end
end
