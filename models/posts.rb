require_relative 'model'

class Posts < Model
  def initialize(config)
    super(config, "posts")
  end

  def last(n)
    query = <<-SQL
      SELECT `id`, `text`, `spawn`, `is_admin`
      FROM `posts`
      ORDER BY `spawn` DESC
      LIMIT #{n};
    SQL

    self.query(query)
  end

  def add(text, ip)
    stamp = Time.now.to_i
    text = Model::escape(text[0...512])
    query = <<-SQL
      INSERT INTO `posts` (`text`, `spawn`, `ip`, `is_admin`)
      VALUES (
        "#{text}",
        #{stamp},
        "#{ip}",
        0
      );
    SQL

    self.query(query)
  end

  def duplicate?(str)    
    last = self.last(1).to_a

    if last.empty?
      return false
    else    
      txt = last[0]["text"]      
      return (txt == str)
    end
  end
end
