# -*- encoding : utf-8 -*-
require 'maruku'

module MarkedUpWithMarukuHelper
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    # Creates an attribute reader on <tt>attrs</tt> which runs MaRuKu over the attribute before
    # returning.
    #   class BlogPost < ActiveRecord::Base
    #     marked_up_with_maruku :text
    #   end
    #
    #   # this is similar to
    #
    #   class BlogPost < ActiveRecord::Base
    #     def text
    #       Maruku.new(self[:text]).to_html
    #     end
    #   end
    def marked_up_with_maruku(*attrs)
      attrs.each do |attr|
        send :define_method, attr.to_sym do
          Maruku.new(self[attr]).to_html
        end
      end
    end
  end
end

class ActiveRecord::Base
  include MarkedUpWithMarukuHelper
end
