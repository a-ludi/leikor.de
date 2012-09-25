atom_feed :language => 'de-DE', :root_url => blog_posts_url do |feed|
  feed.title t('views.blog.feed.title')
  feed.updated(@blog_posts.first.created_at) if @blog_posts.length > 0

  @blog_posts.each do |blog_post|
    feed.entry(blog_post) do |entry|
      entry.title(blog_post.title)
      entry.content(blog_post.body, :type => 'html')
      
      entry.author do |author|
        author.name "LEIKOR" 
      end
    end
  end
end
