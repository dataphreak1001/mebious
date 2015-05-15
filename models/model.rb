require 'mysql2'
require 'json'

class Model
  def initialize(config)
    data = File.read(config)
    data = JSON.parse(data)
    @core = Mysql2::Client.new(
      :host     => data['host'],
      :username => data['user'],
      :password => data['password'],
      :database => data['database']
    )
  end

  def query(txt)
    @core.query(txt)
  end
end
