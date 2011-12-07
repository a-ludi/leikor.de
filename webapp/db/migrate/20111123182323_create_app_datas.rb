# -*- encoding : utf-8 -*-
class CreateAppDatas < ActiveRecord::Migration
  def self.up
    create_table :app_datas do |t|
      t.string :name
      t.text :value
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :app_datas
  end
end
