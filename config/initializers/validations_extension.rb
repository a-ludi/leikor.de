# -*- encoding : utf-8 -*-
require 'maruku'
require 'active_record'

module ValidationsExtension
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    include ActiveRecord::Validations::ClassMethods
    
    # Validates that the specified attributes get parsed as Markdown without error. It takes the
    # same options as ActiveRecord::Validations::ClassMethods#validates_each
    #
    #   class BlogPost < ActiveRecord::Base
    #     validates_markdown :text
    #   end
    def validates_markdown(*attrs)
      validates_each attrs do |record, attr, value|
        begin
          Maruku.new(value).to_html
        rescue MaRuKu::Exception
          record.errors.add attr, :invalid_markup
        end
      end
    end
  end
end

class ActiveRecord::Base
  include ValidationsExtension
end
