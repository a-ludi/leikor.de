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
  
  def render_to_nested_layout(options={})
    options[:outer_layout] = 'application' if options[:outer_layout].nil?
    
    options[:text] = render_to_string options
    options[:layout] = options[:outer_layout]
    render options
  end

  def positional_class(item, collection, user_class='')
    user_class += ' first' if item == collection.first
    user_class += ' last' if item == collection.last
    
    return user_class
  end
  
  def make_if_error_messages_for(object)
    error_messages_for(
      :id => nil,
      :object => object,
      :header_message => nil,
      :class => 'error message'
    ) if flash[:errors_occurred]
  end
  
  def set_focus_to(id)
    javascript_tag "$('#{id}').focus()"
  end
end
