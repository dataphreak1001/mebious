class Post < ActiveRecord::Base
  def self.add(text, ip)
    stamp = Time.now.to_i
    text = text[0...512]

    self.create({
      :spawn    => stamp,
      :text     => text,
      :ip       => ip,
      :is_admin => 0
    })
  end

  def self.duplicate?(str)    
    last = self.last(1)

    if last.empty?
      return false
    else    
      txt = last[0].text
      return (txt == str)
    end
  end
end
