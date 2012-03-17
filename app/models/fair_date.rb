class FairDate < ActiveRecord::Base
  validates_presence_of :from_date, :to_date, :name
  
  def comment
    Maruku.new(self[:comment]).to_html_document
  end
end
