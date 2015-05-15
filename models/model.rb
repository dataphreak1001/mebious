require 'mysql2'
require 'json'

class Model
  def initialize(config, table)
    data = File.read(config)
    data = JSON.parse(data)
    @core = Mysql2::Client.new(
      :host     => data['host'],
      :username => data['user'],
      :password => data['password'],
      :database => data['database']
    )

    @table = table
  end

  # override the table and
  # just execute the query
  def query(txt)
    @core.query(txt)
  end
end
