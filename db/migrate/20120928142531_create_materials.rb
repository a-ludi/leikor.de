class CreateMaterials < ActiveRecord::Migration
  def self.up
    create_table :materials do |t|
      t.string :name
      t.string :picture_filename
      t.string :picture_content_type
      t.binary :picture_file

      t.timestamps
    end
  end

  def self.down
    drop_table :materials
  end
end
