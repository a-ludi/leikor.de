xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Neuigkeiten von LEIKOR"
    xml.description "Die neusten Meldungen der Firma LEIKOR"
    xml.link blog_posts_url

    for blog_post in @blog_posts
      xml.item do
        xml.title blog_post.title
        xml.description blog_post.body
        xml.pubDate blog_post.created_at.to_s(:rfc822)
        xml.link blog_post_url(blog_post)
        xml.guid blog_post_url(blog_post)
      end
    end
  end
end
