class AddIndicesToVariousTables < ActiveRecord::Migration
  def self.up
    add_index :secure_user_requests, :external_id, :unique => true, :name => :by_external_id
    add_index :users, :login, :unique => true, :name => :by_login
    add_index :app_datas, :name, :unique => true, :name => :by_name
    add_index :colors, :label, :unique => true, :name => :by_label
    add_index :articles, :article_number, :unique => true, :name => :by_article_number
  end

  def self.down
    remove_index :secure_user_requests, :name => :by_external_id
    remove_index :users, :name => :by_login
    remove_index :app_datas, :name => :by_name
    remove_index :colors, :name => :by_label
    remove_index :articles, :name => :by_article_number
  end
end
