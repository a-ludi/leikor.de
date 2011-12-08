# encoding: utf-8
# This fixes the bug in:
# /activesupport-2.3.10/lib/active_support/core_ext/object/blank.rb:68
module StringBlankPatch
  module String
    def blank?
      self.dup.as_bytes !~ /\S/
    end
  end
end
 
class String
  include StringBlankPatch::String
end
