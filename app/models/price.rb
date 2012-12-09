class Price < ActiveRecord::Base
  default_scope :order => 'amount ASC'
  
  belongs_to :article
  
  validates_presence_of :article
  validates_numericality_of :amount, :greater_than => 0.0
  validates_numericality_of :minimum_count, :greater_than_or_equal_to => 0, :only_integer => true
  validates_uniqueness_of :amount, :scope => [:article_id]
  validates_uniqueness_of :minimum_count, :scope => [:article_id]
  validate :rising_minimum_count_means_falling_amount

protected
  
  def rising_minimum_count_means_falling_amount
    if self.article.present?
      rising_minimum_counts = self.article.prices.all :order => 'minimum_count ASC'
      falling_amounts = self.article.prices.all :order => 'amount DESC'

      if not rising_minimum_counts == falling_amounts
        self.errors.add :amount, :rising_minimum_count_means_falling_amount
      end
    end
  end
end
