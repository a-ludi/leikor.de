# -*- encoding: utf-8 -*-

class Color < ActiveRecord::Base
  HEX_FORMAT = /^#([a-fA-F0-9]{3}|[a-fA-F0-9]{6})$/
  
  validates_presence_of :label, :hex
  validates_uniqueness_of :label
  validates_format_of :hex, :with => HEX_FORMAT
end
