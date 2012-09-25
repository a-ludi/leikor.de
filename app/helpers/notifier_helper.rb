# -*- encoding: utf-8 -*-

module NotifierHelper
  def image_url source
    path = image_path source
    host = root_url
    
    host + path[1..-1]
  end
  
  def blog_post_url_with_login_if_required blog_post
    if blog_post.is_published?
      blog_post_url blog_post
    else
      new_session_url(:referer => blog_post_path(blog_post), :protocol => 'https')
    end
  end
end
