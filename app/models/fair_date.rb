class FairDate < ActiveRecord::Base
  marked_up_with_maruku :comment
  
  validates_presence_of :from_date, :to_date, :name
  validates_markdown :comment
end
