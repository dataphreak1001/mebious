xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "example.com"
    xml.description "What's happening at the present day, present time."
    xml.link "example.com"
    xml.pubDate Time.now.rfc822
    xml.lastBuildDate Time.now.rfc822
    
    @posts.each { |post|
      xml.item {
        xml.title post.text
        xml.description post.text
        xml.link "example.com"
        xml.pubDate Time.at(post.spawn).rfc822
        xml.guid "example.com/##{post.id}"
      }        
    }
  end
end
