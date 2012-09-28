# -*- encoding : utf-8 -*-
module AssertionsHelper::ActiveRecordAssertions
  def assert_errors_on(obj, options={})
    run_validations obj
    if options[:on].is_a? Symbol
      options[:message] = message(options[:message]) {
          "expected errors on <#{obj.class.to_s}\##{options[:on].to_s}>" }
      refute obj.errors.on(options[:on]).blank?, options[:message]
    else
      options[:message] = message(options[:message]) {
          "expected errors on <#{obj.class.to_s}>" }
      assert obj.errors.any?, options[:message]
    end
  end
  
  def refute_errors_on(obj, options={})
    run_validations obj
    if options[:on].is_a? Symbol
      options[:message] = message(options[:message]) {
          "expected no errors on <#{obj.class.to_s}\##{options[:on].to_s}>, but found:\n#{obj.errors.on(options[:on])}" }
      assert obj.errors.on(options[:on]).blank?, options[:message]
    else
      options[:message] = message(options[:message]) {
          "expected no errors on <#{obj.class.to_s}>, but found:\n#{obj.errors.full_messages}" }
      assert obj.errors.empty?, options[:message]
    end
  end
  alias :assert_no_errors_on :refute_errors_on
  
  def assert_creates_record_from(record_class, options={})
    message = "record of class #{record_class} could not be generated from #{options.inspect}"
    assert record_class.create(options).save, message
  end
  
  def assert_destroyed(record, msg=nil)
    assert record.destroyed?, (msg || "<#{record}> is not destroyed")
  end
  
  def assert_new_record(record, msg=nil)
    assert record.new_record?, (msg || "<#{record}> is not new")
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
