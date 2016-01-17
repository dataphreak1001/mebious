require_relative 'model'

class API < Model
  def initialize(config)
    super(config, "api")
  end

  def allowed?(key)
    query = <<-SQL
      SELECT * FROM `api`
      WHERE `apikey` = ? 
      LIMIT 1;
    SQL

    res = self.query(query, [key])

    if res.length > 0
      return true
    else
      return false
    end
  end
end
