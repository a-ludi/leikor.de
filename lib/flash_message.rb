# encoding: utf-8

class FlashMessage < ActionController::Base
  @class = nil
  @title = ''
  @text = ''
  
  
  def <<(obj)
    case obj
      when String then @text += text
      when Hash then @text += render_to_string(obj)
    end
  end
  
  def self.error(text=nil)
    FlashMessage << text.to_s
    @class = :error
  end
  
  def self.success(text=nil)
    FlashMessage << text.to_s
    flash[:message]
    
    @class = :success
  end
end

