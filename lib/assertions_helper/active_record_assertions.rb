# -*- encoding : utf-8 -*-
module AssertionsHelper::ActiveRecordAssertions
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
  
  def assert_no_errors_on(obj, options={})
    if options[:on].is_a? Symbol
      options[:message] = "expected no errors on <#{obj}.#{options[:on]}>" unless options[:message]
      obj.valid?
      assert ! obj.errors.on(options[:on]), options[:message]
    else
      options[:message] = "expected no errors on <#{obj}>" unless options[:message]
      obj.valid?
      assert_empty obj.errors, options[:message]
    end
  end
  
  def assert_creates_record_from(record_class, options={})
    message = "record of class #{record_class} could not be generated from #{options.inspect}"
    assert record_class.create(options).save, message
  end
end
