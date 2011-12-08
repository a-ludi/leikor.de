# -*- encoding : utf-8 -*-
class RenameTypeColumnInAppData < ActiveRecord::Migration
  def self.up
    rename_column :app_datas, :type, :data_type
  end

  def self.down
    rename_column :app_datas, :data_type, :type
  end
end
