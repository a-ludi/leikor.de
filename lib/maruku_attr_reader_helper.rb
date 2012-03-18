# -*- encoding : utf-8 -*-
require 'maruku'

module HasMarukuMarkupHelper
  module ClassMethods
    # Creates an attribute reader on <tt>attrs</tt> which runs MaRuKu over the attribute before
    # returning. It's similar to defining
    # 
    #   class BlogPost < ActiveRecord::Base
    #     def text
    #       Maruku.new(self[:text]).to_html
    #     end
    #   end
    def has_maruku_markup(*attrs)
      validates_each attrs do |record, attr, value|
        begin
          Maruku.new(value).to_html
        catch MaRuKu::Exception
          record.errors.add attr, :invalid_markup
        end
      end
    end
  end
end

class ActiveRecord::Base
  class << self
    include ValidationsHelper::ClassMethods
  end
end
