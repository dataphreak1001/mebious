xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "mebious"
    xml.description "What's happening at the present day, present time."
    xml.link "example.com"
		xml.pubDate Time.now
		xml.lastBuildDate Time.now
    
    @posts.each { |post|
      xml.item {
        xml.title post['text']
        xml.description post['text']
        xml.link "example.com"
        xml.pubDate Time.at(post['spawn']).rfc822
      }        
    }
  end
end
