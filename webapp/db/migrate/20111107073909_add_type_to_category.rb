class AddTypeToCategory < ActiveRecord::Migration
  def self.up
    add_column(:categories, :type, :string)
    remove_column(:categories, :description)
    
    Category.reset_column_information
    
    for c in Category.all
      if c.root?
        c.type = nil
      else
        c.type = 'Subcategory'
      end
      c.save!
    end
  end
  
  def self.down
    remove_column(:categories, :type)
    add_column(:categories, :description, :text)
  end
end
