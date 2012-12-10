# encoding: utf-8

# Adds support to read localized numbers from strings.
module LocalizedBigDecimalPatch
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    # Converts a localized number string to +BigDecimal+.
    #
    # ==== Options
    # * <tt>:locale</tt>  - specify a custom locale; defaults to the current
    #                       locale
    def from_s(string, options={})
      options.symbolize_keys!

      defaults = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}

      delimiter = options[:delimiter] || defaults[:delimiter]
      separator = options[:separator] || defaults[:separator]

      number = string.gsub(delimiter, "").gsub(separator, ".")
      BigDecimal.new(number)
    end
  end
end
 
class BigDecimal
  include LocalizedBigDecimalPatch
end
