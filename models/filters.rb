class Filter < ActiveRecord::Base
  def self.filtered?(text)
    self.all.map { |word|
      regex = Regexp.new(word.word, "i")
      !!regex.match(text)
    }.include? true
  end
end
