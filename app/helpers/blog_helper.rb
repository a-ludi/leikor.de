# -*- encoding : utf-8 -*-

module BlogHelper
  def update_readers_from_groups
    pass_groups = "Object.toQueryString({groups: $('#{dom_id(@blog_post, :groups)}').value})"
    remote_function(
      :url => readers_blog_posts_path,
      :with => pass_groups,
      :method => :get,
      :update => 'readers',
      :after => "$('readers').update('<div class=\"field\">#{loading_animation}</div>')")
  end
end
