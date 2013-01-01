class Price < ActiveRecord::Base
  default_scope :order => 'amount ASC'
  
  belongs_to :article
  
  validates_presence_of :article
  validates_numericality_of :amount, :greater_than => 0.0
  validates_numericality_of :minimum_count, :greater_than_or_equal_to => 0, :only_integer => true

  def active?
    !self.new_record? or
    self.minimum_count.present? or
    self.amount.present?
  end
  
  def inactive?
    !self.active?
  end
end
