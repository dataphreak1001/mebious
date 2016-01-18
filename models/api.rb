class API < ActiveRecord::Base 
  self.table_name = "api"

  def self.allowed?(key)
    res = self.where(:apikey => key)

    if res.length > 0
      return true
    else
      return false
    end
  end
end
