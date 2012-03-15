# encoding: utf-8

# This makes translated Durations available
include ActionController::Translation

module ActiveSupport
  class Duration
    def inspect #:nodoc:
      consolidated = parts.inject(::Hash.new(0)) { |h,part| h[part.first] += part.last; h }
      
      [:years, :months, :weeks, :days, :hours, :minutes, :seconds].map do |length|
        n = consolidated[length]
        translate(length, :count => n, :scope => 'datetime.duration') if n.nonzero?
      end.compact.to_sentence
    end
  end
end
