# -*- encoding : utf-8 -*-

class Subcategory < Category
  belongs_to :category
  has_many :articles, :dependent => :destroy

  validates_presence_of :category_id, :message => 'activerecord.errors.messages.internal_error'
  
  def self.human_name
    'Unterkategorie'
  end
  
  def url_hash(options={})
    hash = {:subcategory => to_param}.merge(options)
    category.url_hash(hash)
  end

  def next_article_ord
    if article = articles.last
      article.ord + 1
    else
      0
    end
  end
end
