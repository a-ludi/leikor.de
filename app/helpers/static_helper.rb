# -*- encoding : utf-8 -*-
module StaticHelper
  def static_link_to(path, options={}, html_options=nil)
    if StaticController::REGISTERED_PAGES[path]
      label = options.delete(:label) {|k| StaticController::REGISTERED_PAGES[path][:name] }
      link_to label, static_path(path, options), html_options
    else
      raise ActionController::RoutingError, "static_link_to failed to generate from <#{path.inspect}> expected one of <#{StaticController::REGISTERED_PAGES.keys.inspect}>"
    end
  end

  def border_radius(options={})
    if options.is_a? String
      radius = options
      <<-OUT.gsub ' '*10, ''
        -webkit-border-radius: #{radius};
        -moz-border-radius: #{radius};
        border-radius: #{radius};
      OUT
    elsif options.is_a? Hash
      if options[:left]
        options[:topleft] = options[:left]
        options[:bottomleft] = options[:left]
      end
      if options[:right]
        options[:topright] = options[:right]
        options[:bottomright] = options[:right]
      end
      if options[:top]
        options[:topright] = options[:top]
        options[:topleft] = options[:top]
      end
      if options[:bottom]
        options[:bottomright] = options[:bottom]
        options[:bottomleft] = options[:bottom]
      end
      
      out = ''
      out += border_radius options[:all] if options[:all]
      
      out += <<-OUT.gsub ' '*10, '' if options[:topleft]
        -webkit-border-top-left-radius: #{options[:topleft]};
        -moz-border-radius-topleft: #{options[:topleft]};
        border-top-left-radius: #{options[:topleft]};
      OUT
      
      out += <<-OUT.gsub ' '*10, '' if options[:topright]
        -webkit-border-top-right-radius: #{options[:topright]};
        -moz-border-radius-topright: #{options[:topright]};
        border-top-right-radius: #{options[:topright]};
      OUT
      
      out += <<-OUT.gsub ' '*10, '' if options[:bottomleft]
        -webkit-border-bottom-left-radius: #{options[:bottomleft]};
        -moz-border-radius-bottomleft: #{options[:bottomleft]};
        border-bottom-left-radius: #{options[:bottomleft]};
      OUT
      
      out += <<-OUT.gsub ' '*10, '' if options[:bottomright]
        -webkit-border-bottom-right-radius: #{options[:bottomright]};
        -moz-border-radius-bottomright: #{options[:bottomright]};
        border-bottom-right-radius: #{options[:bottomright]};
      OUT
      
      return out
    end
  end
  
  def palette(color)
    case color
      when :white then '#ffffff'
      when :black then '#000000'
      when :dark_red then '#a80000'
      when :mid_red then '#fe0000'
      when :light_red then '#ffc3c3'
      when :dark_green then '#00a663'
      when :light_green then '#d9fff0'
      when :dark_blue then '#0065a8'
      when :mid_blue then '#0099ff'
      when :light_blue then '#d9f0ff'
      when :dark_gray then '#333333'
      when :darker_gray then '#aaaaaa'
      when :mid_gray then '#cccccc'
      when :lighter_gray then '#dddddd'
      when :light_gray then '#eeeeee'
      else raise ActionView::ActionViewError, "unknown color: <#{color.inspect}>"
    end
  end
  alias :p :palette
end
