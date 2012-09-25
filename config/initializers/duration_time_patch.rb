# encoding: utf-8

# This makes minutes, hours

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Numeric #:nodoc:
      module Time
        def seconds
          ActiveSupport::Duration.new(self, [[:seconds, self]])
        end
        alias :second :seconds

        def minutes
          ActiveSupport::Duration.new(self * 60.seconds, [[:minutes, self]])
        end
        alias :minute :minutes  
        
        def hours
          ActiveSupport::Duration.new(self * 60.minutes, [[:hours, self]])
        end
        alias :hour :hours
        
        def days
          ActiveSupport::Duration.new(self * 24.hours, [[:days, self]])
        end
        alias :day :days

        def weeks
          ActiveSupport::Duration.new(self * 7.days, [[:days, self * 7]])
        end
        alias :week :weeks
        
        def fortnights
          ActiveSupport::Duration.new(self * 2.weeks, [[:days, self * 14]])
        end
        alias :fortnight :fortnights
      end
    end
  end
end
