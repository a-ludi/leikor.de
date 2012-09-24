xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", 'xmlns:atom' => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Neuigkeiten von LEIKOR"
    xml.description "Die neusten Meldungen der Firma LEIKOR"
    xml.link blog_posts_url
    xml.language 'de-DE'
    xml.atom :link, :href => blog_posts_url(:format => :rss), :rel => "self", :type => "application/rss+xml"

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
