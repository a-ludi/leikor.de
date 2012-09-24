# -*- encoding : utf-8 -*-

module BlogHelper
  def update_readers_from_groups
    input_dom_id = dom_id(@blog_post, :groups)
    pass_groups = "Object.toQueryString({groups: $('#{input_dom_id}').value})"
    remote_function(
      :url => readers_blog_posts_path,
      :with => pass_groups,
      :method => :get,
      :after => "$('#{input_dom_id}').updatePreview('<div class=\"field\">#{escape_javascript loading_animation}</div>')",
      :complete => "$('#{input_dom_id}').updatePreview(request.responseText)")
  end
end
