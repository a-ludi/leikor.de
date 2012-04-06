class AddArticleIdToPictures < ActiveRecord::Migration
  def self.up
    add_column(:pictures, :article_id, :integer)
  end

  def self.down
    remove_column(:pictures, :article_id)
  end
end
