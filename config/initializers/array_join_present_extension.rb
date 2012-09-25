# encoding: utf-8

module ArrayPresentExtension
  def join_present separator=' '
    self.reject{|e| e.blank?}.join separator
  end
end
 
class Array
  include ArrayPresentExtension
end
