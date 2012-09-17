# encoding: utf-8

class FlashMessage
  DEFAULTS = {:klass => nil, :title => nil, :text => ''}
  
  attr_accessor :text
  
  # Returns the title or translation string of this message. If not explicitly
  # set <tt>FlashMessage</tt> will try to guess an apropriate title like
  # <tt>translate @klass.to_s, :scope => 'flash_message.title'<tt>. If none is
  # found <tt>flash_message.title.default</tt> will be used.
  def title
    unless @title.blank?
      @title
    else
      @title = klass_or_default_title
    end
  end

  attr_writer :title
  
  # Returns <tt>true</tt> if the return value of title should be fed into
  # <tt>translate</tt>.
  def translate_title?
    title
    @translate_title
  end
  
  attr_writer :translate_title
  
  # Returns <tt>@klass.to_s</tt>.
  def klass; @klass.to_s; end
  
protected

  attr_writer :klass
  
private
  
  def klass_or_default_title
    self.translate_title = true
    translate_klass = @klass.to_s
    translate_klass = 'default' if translate_klass.blank?
    "flash_message.title.#{translate_klass}"
  end

public
  
  # Returns a hash which can directly be passed to <tt>render</tt>. Typical usage looks like:
  #
  #   <div id="message">
  #     <%= render flash[:message].render_options %>
  #   </div>
  def render_options
    case @text
      when Hash then @text
      else {:text => @text}
    end
  end
  
public
  
  def initialize(options={})
    options = FlashMessage::DEFAULTS.merge options
    @klass = options[:klass]
    @title = options[:title]
    @text = options[:text]
    @translate_title = false
  end
  
  # Just pass a text and optionally a title of the error message. If no title is given it will be
  # looked up at <tt>flash_message.title.error</tt>.
  def error(text, title=nil)
    set_message :klass => :error, :title => title, :text => text
  end
  
  # Just pass a text and optionally a title of the (success) message. If no title is given it will
  # be looked up at <tt>flash_message.title.success</tt>.
  def success(text=nil, title=nil)
    set_message :klass => :success, :title => title, :text => text
  end
  
  # Append text to the message or set a options <tt>Hash</tt> to be passed to <tt>render</tt>.
  def <<(obj)
    case obj
      when Hash then @text = obj
      else @text += "<p>#{obj.to_s}</p>"
    end
  end
  
  # Returns <tt>@text.blank?</tt>.
  def empty?
    @text.blank?
  end
  
  # Clears text, title and class.
  def clear!
    @text = ''
    @klass = @title = nil
  end

private

  def set_message(options)
    @klass = options[:klass]
    @title = options[:title]
    self << options[:text]
  end
end

