# -*- encoding: utf-8 -*-

module NotifierHelper
  def image_url source
    path = image_path source
    host = root_url
    
    host + path[1..-1]
  end
end
