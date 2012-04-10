class CreateBlogPosts < ActiveRecord::Migration
  def self.up
    create_table :blog_posts do |t|
      t.string :public_id
      t.string :title
      t.text :body
      t.belongs_to :author
      t.belongs_to :editor
      t.string :groups
      t.boolean :is_mailed
      t.boolean :is_published

      t.timestamps
      t.primary_key :public_id
    end
  end

  def self.down
    drop_table :blog_posts
  end
end
