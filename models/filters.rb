class Filter < ActiveRecord::Base
  def self.filtered?(text)
    self.all.map { |word|
      regex = /\b#{word.word}\b/i
      !!regex.match(text)
    }.include? true
  end
end
