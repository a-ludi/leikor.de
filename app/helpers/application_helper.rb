# -*- encoding : utf-8 -*-

module ApplicationHelper
  # To create a piped menu use:
  #
  #     text_menu (link_to(l1) if c1),(link_to(l2) if c2),(link_to(l3) if c3)
  #
  # To use an alternate separator (e.g. '-') use:
  #
  #     text_menu (link_to(l1) if c1),(link_to(l2) if c2),(link_to(l3) if c3), :separator => '-'
  def text_menu(*collection)
    separator = '|'
    if collection.last.is_a? Hash
      separator ||= collection.last[:separator]
      collection.pop
    end
    
    collection.compact.join(" #{separator} ")
  end
  
  def brick(name, object=nil)
    render :partial => "bricks/#{name.to_s}", :object => object
  end
  
  def a_button_to(name, options={}, html_options=nil)
    button_options = {:type => 'button', :value => name}
    [:tabindex].each do |key|
      unless html_options[key].blank?
        button_options[key] = html_options[key]
        html_options.delete key
      end
    end unless html_options.nil?
    
    button = tag :input, button_options, false    
    link_to button, options, html_options
  end
  
  def positional_class(*args)
    if args[0].is_a? Fixnum and args[1].is_a? Fixnum
      index_based_positional_class *args
    elsif args[1].respond_to? :first and args[1].respond_to? :last
      collection_based_positional_class *args
    else
      raise ArgumentError, 'positional_class: invalid params <#{args.inspect}>'
    end
  end
  
  def collection_based_positional_class(item, collection, user_class='')
    classes = user_class.blank? ? [] : [user_class]
    classes << 'first' if item == collection.first
    classes << 'last' if item == collection.last
    
    return classes.join ' '
  end
  
  def index_based_positional_class(index, length, user_class='')
    classes = user_class.blank? ? [] : [user_class]
    classes << 'first' if index == 0
    classes << 'last' if index == length - 1
    # index 0 is the first line therefore it's odd ... that's odd, ey?
    classes << (index % 2 == 0 ? 'odd' : 'even')
    
    return classes.join ' '
  end
  
  def make_if_error_messages_for(record)
    error_messages_for(
      :id => nil,
      :object => record,
      :header_message => nil,
      :class => 'error message'
    ) unless record.errors.empty?
  end
  
  def set_focus_to(html_id)
    javascript_tag "$('#{html_id}').focus()"
  end
  
  def css_dimensions(width, height, unit=nil)
    if width.is_a? Numeric and height.is_a? Numeric and unit.is_a? String
      width = width.to_s + unit
      height = height.to_s + unit
    end
    
    "width: #{width}; height: #{height};"
  end
  
  def open_popup
    'openPopup(this.href); return false'
  end
  
  def handle_if_superuser(options={})
    if (logged_in? Employee and (options.empty? or options[:and])) or options[:or]
      '<div class="handle">&nbsp;</div>'
    else
      ''
    end
  end
  
  def clear_float tag_name=:div
    content_tag tag_name, nil, :class => 'clear'
  end
  
  def hard_spaced(text)
    text.gsub ' ', '&nbsp;'
  end
  
  def loading_animation(options={})
    options = {
      :size => :medium,
      :class => 'loading_animation toolbutton'
    }.merge options
    
    options[:size] = case options[:size].to_sym
      when :small
        options[:path] = 'small'
        "24x24"
      when :medium
        options[:path] = 'medium'
        "32x32"
      else
        options[:size]
    end
    
    width, height = options[:size].split('x').map{|s| s.to_i}
    options[:style] ||= css_dimensions(width, height, 'px')
    
    image_tag "pictogram/#{options[:path]}/loading.gif", options
  end
end
