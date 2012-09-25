# -*- encoding : utf-8 -*-
module AssertionsHelper::LoggerAssertions
  def assert_logs(msg=nil, &proc)
    assertion_method = Proc.new {|logged, msg| assert logged, msg}
    test_logs assertion_method, (msg || "no message logged"), &proc
  end

  def refute_logs(msg=nil, &proc)
    assertion_method = Proc.new {|logged, msg| refute logged, msg}
    test_logs assertion_method, (msg || "message logged"), &proc
  end

private

  def test_logs(assertion_method, msg, &proc)
    @controller.logger = MockLogger.new @controller.logger
    begin
      yield
      logged = @controller.logger.logged?
    ensure
      @controller.logger = @controller.logger.original_logger
    end
    assertion_method.call logged, msg
  end
  
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
end
