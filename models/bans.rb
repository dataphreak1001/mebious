require_relative 'model'

class Bans < Model
  def initialize(config)
    super(config, "bans")
  end

  def banned?(ip)
    query = <<-SQL
      SELECT * FROM `bans`
      WHERE `ip` = "#{ip}"
      LIMIT 1
    SQL

    res = self.query(query)

    if res.count > 0
      return true
    else
      return false
    end
  end
end
