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

  # dear asshole who i had to implement this for:
  # fuck you. fite me bitch.
  def self.spam?(text, ip)
    last = self.last(4)

    if last.empty? or last.length < 4
      return false
    end

    spam = last.select { |post| post.ip != ip }.empty?
    unoriginal = last.select { |post| post.text.strip != text.strip }.empty?

    if spam or unoriginal
      return true
    else
      return false
    end
  end
end
