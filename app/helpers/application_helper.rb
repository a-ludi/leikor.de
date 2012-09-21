# -*- encoding : utf-8 -*-

module ApplicationHelper
  def meta_keywords
    keywords = %w(LEIKOR Großhandel Grosshandel Messe Messetermin Naturmaterialien Teak-Holz
        Teakholz Baumwolle Seide)
    keywords << Category.all.map{|c| c.name}
    keywords.join_present ','
  end
  
  # To create a piped menu use:
  #
  #     text_menu (link_to(l1) if c1),(link_to(l2) if c2),(link_to(l3) if c3)
  #
  # To use an alternate separator (e.g. '-') use:
  #
  #     text_menu (link_to(l1) if c1),(link_to(l2) if c2),(link_to(l3) if c3), :separator => '-'
  def text_menu(*collection)
    separator = ' | '
    if collection.last.is_a? Hash
      separator ||= collection.last[:separator]
      collection.pop
    end
    
    collection.compact.join(separator)
  end
  
  def brick(name, object=nil)
    render :partial => "bricks/#{name.to_s}", :object => object
  end
  
  def toolbutton_to(name, path, options={})
    options = make_options_for_toolbutton name, options

    link_to options.delete(:content), path, options
  end
  
  def toolbutton_to_remote(name, options={}, html_options=nil)
    toolbutton_options = {:size => options[:size], :content => options[:content]}.merge(options[:html] || {})
    toolbutton_options = make_options_for_toolbutton name, toolbutton_options
    content = toolbutton_options.delete(:content)
    options[:html] = toolbutton_options

    link_to_remote content, options, html_options
  end
  
  private
  
  def make_options_for_toolbutton(name, options)
    if File::extname(name.to_s).blank?
      title = name.to_s.humanize
      file_name = name.to_s + '.png'
    else
      title = File::basename(name.to_s, File::extname(name.to_s)).humanize
      file_name = name.to_s
    end
    
    options[:size] ||= :medium
    options[:title] ||= title
    options[:class] = ['toolbutton', options[:size], options[:class]].join_present
    img_path = image_path "pictogram/#{options[:size]}/#{file_name}"
    toolbutton_style = "background-image: url('#{img_path}');"
    options[:style] = [options[:style], toolbutton_style].join_present
    options[:content] ||= ''
    options.delete(:size)
    
    options
  end
  
  public
  
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
    classes = [
      user_class,
      ('first' if item == collection.first),
      ('last' if item == collection.last)
    ]
    
    return classes.join_present
  end
  
  def index_based_positional_class(index, length, user_class='')
    classes = [
      user_class,
      ('first' if index == 0),
      ('last' if index == length - 1),
      (index % 2 == 0 ? 'odd' : 'even')
    ]
    # index 0 is the first line therefore it's odd ... that's odd, ey?
    
    return classes.join_present
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
    options[:class] = ['blank', options[:class]].join_present
    options[:style] = ['cursor: wait;', options[:style]].join_present
    
    toolbutton_to 'loading.gif', '#', options
  end
end
