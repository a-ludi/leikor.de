# -*- encoding : utf-8 -*-

module ApplicationHelper
  def a_button_to(label, href, html_options={})
    attributes = []
    html_options.each{|key, value| attributes << "#{key}=\"#{value}\""}
    "<a href=\"#{href}\" #{attributes.join ' '}><input type=\"button\" value=\"#{label}\" /></a>"
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
    user_class += ' first' if item == collection.first
    user_class += ' last' if item == collection.last
    
    return user_class
  end
  
  def index_based_positional_class(index, length, user_class='')
    user_class += ' first' if index == 0
    user_class += ' last' if index == length - 1
    user_class += index % 2 == 0 ? ' even' : ' odd'
    
    user_class
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
  
  def open_popup
    'openPopup(this.href); return false'
  end
end
