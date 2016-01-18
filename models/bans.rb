class Ban < ActiveRecord::Base 
  def self.banned?(ip)
    res = self.where(:ip => ip)

    if res.length > 0
      return true
    else
      return false
    end
  end
end
