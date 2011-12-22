class Color < ActiveRecord::Base
  HEX_FORMAT = /^#([a-fA-F0-9]{3}|[a-fA-F0-9]{6})$/
  
  validates_presence_of :labe, :hex
  validates_uniqueness_of :label
  validates_format_of :hex, HEX_FORMAT
end
