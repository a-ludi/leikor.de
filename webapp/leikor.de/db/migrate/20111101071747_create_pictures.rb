class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :name
      t.string :short_description
      t.integer :article_id
      t.text :data

      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
