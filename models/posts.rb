require_relative 'model'

class Posts < Model
  def initialize(config)
    super(config, "posts")
  end

  def last(n)
    query = <<-SQL
      SELECT * FROM `posts`
      ORDER BY `spawn` DESC
      LIMIT #{n};
    SQL

    self.query(query)
  end

  def add(text)
    stamp = Time.now.to_i
    text = Model::escape(text[0...512])
    query = <<-SQL
      INSERT INTO `posts` (`text`, `spawn`, `is_admin`)
      VALUES (
        "#{text}",
        #{stamp},
        0
      );
    SQL

    self.query(query)
  end
end
