class FairDate < ActiveRecord::Base
  validates_presence_of :from_date, :to_date, :name
end
