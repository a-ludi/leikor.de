# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def fetch_categories(id=nil)
    @categories = Category.find(
      :all,
      :conditions => {:type => :category}
    )
    
    unless id.nil?
      category = Category.from_param id
      unless category.is_a? Subcategory
        @category = category
      else
        @subcategory = category
        @category = @subcategory.category
      end
    end
  end
  
  def positional_class(item, collection, user_class='')
    user_class += ' first' if item == collection.first
    user_class += ' last' if item == collection.last
    
    return user_class
  end
  
  def make_if_error_messages_for(record)
    error_messages_for(
      :id => nil,
      :object => record,
      :header_message => nil,
      :class => 'error message'
    ) unless record.errors.empty?
  end
  
  def set_focus_to(id)
    javascript_tag "$('#{id}').focus()"
  end
end
