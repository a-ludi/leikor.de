# encoding: utf-8
require 'active_support'

module ActiveSupport
  class Duration
    require 'i18n'
    # Returns a translated represantation of this Duration
    # 
    #   # with locale :en
    #   >> (1.days + 3.minutes).inspect
    #   => 1 day and 3 minutes
    #
    #   # with locale :de
    #   >> (1.days + 3.minutes).inspect
    #   => 1 Tag und 3 Minuten
    # 
    # Pluralized translations in <tt>datetime.duration</tt> will be neccessary.
    # This could be your german locale file:
    # 
    #   de:
    #     datetime:
    #       duration:
    #         seconds:
    #           one: "1 Sekunde"
    #           other: "%{count} Sekunden"
    #         minutes:
    #           one: "1 Minute"
    #           other: "%{count} Minuten"
    #         hours:
    #           one: "1 Stunde"
    #           other: "%{count} Stunden"
    #         days:
    #           one: "1 Tag"
    #           other: "%{count} Tage"
    #         weeks:
    #           one: "1 Woche"
    #           other: "%{count} Wochen"
    #         months:
    #           one: "1 Monat"
    #           other: "%{count} Monate"
    #         years:
    #           one: "1 Jahr"
    #           other: "%{count} Jahre"
    def to_s
      consolidated = parts.inject(::Hash.new(0)) { |h,part| h[part.first] += part.last; h }
      
      [:years, :months, :weeks, :days, :hours, :minutes, :seconds].map do |length|
        n = consolidated[length]
        I18n::translate(length, :count => n, :scope => 'datetime.duration') if n.nonzero?
      end.compact.to_sentence
    end
  end
end
