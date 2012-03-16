# encoding: utf-8

class FlashMessage < ActionController::Base
  include ActionController::Translation
  DEFAULTS = {:klass => nil, :title => nil, :text => ''}
  
  attr_reader :text
  attr_writer :title
  
  def klass; @klass.to_s; end
  
  def title
    return @title  unless @title.blank?
    
    case @klass
      when :error then t 'flash_message.title.error'
      when :success then t 'flash_message.title.success'
      else t 'flash_message.title.default'
    end
  end
  
protected

  attr_writer :klass
  
public
  
  def initialize(options={})
    options = FlashMessage::DEFAULTS.merge options
    @klass = options[:klass]
    @title = options[:title]
    @text = options[:text]
  end
  
  def error(text=nil, title=nil)
    set_message :klass => :error, :title => title, :text => text
  end
  
  def success(text=nil, title=nil)
    set_message :klass => :success, :title => title, :text => text
  end
  
  def <<(obj)
    case obj
      when Hash then @text += render_to_string(obj)
      else @text += "<p>#{obj.to_s}</p>"
    end
  end
  
  def empty?
    @text.blank?
  end
  
  def clear!
    @text = ''
    @klass = @title = nil
  end

private

  def set_message(options)
    self.klass = options[:klass]
    self.title = options[:title]
    self << options[:text]
  end
end

