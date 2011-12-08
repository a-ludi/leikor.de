class FairDate < ActiveRecord::Base
  validates_presence_of :from, :to, :name
end
