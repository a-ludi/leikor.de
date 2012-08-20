# -*- encoding : utf-8 -*-
module AssertionsHelper::ActiveRecordAssertions
  def assert_errors_on(obj, options={})
    run_validations obj
    if options[:on].is_a? Symbol
      options[:message] ||= "expected errors on <#{obj}.#{options[:on]}>"
      refute obj.errors.on(options[:on]).blank?, options[:message]
    else
      options[:message] ||= "expected errors on <#{obj}>"
      assert obj.errors.any?, options[:message]
    end
  end
  
  def assert_no_errors_on(obj, options={})
    run_validations obj
    if options[:on].is_a? Symbol
      options[:message] ||= "expected no errors on <#{obj}.#{options[:on]}>"
      assert obj.errors.on(options[:on]).blank?, options[:message]
    else
      options[:message] ||= "expected no errors on <#{obj}>"
      assert obj.errors.empty?, options[:message]
    end
  end
  
  def assert_creates_record_from(record_class, options={})
    message = "record of class #{record_class} could not be generated from #{options.inspect}"
    assert record_class.create(options).save, message
  end
  
  def assert_destroyed(record, msg=nil)
    assert record.destroyed?, (msg || "<#{record}> is not destroyed")
  end

private
  
  def run_validations(obj)
    obj.instance_eval do
      run_callbacks(:validate)
      validate

      if new_record?
        run_callbacks(:validate_on_create)
        validate_on_create
      else
        run_callbacks(:validate_on_update)
        validate_on_update
      end
    end
  end
end
