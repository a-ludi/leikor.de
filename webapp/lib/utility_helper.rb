module UtilityHelper
  def self.delimited(regexp)
    Regexp.new "^#{regexp.source}$", regexp.options
  end
end

