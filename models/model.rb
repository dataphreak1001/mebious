require 'mysql2'
require 'json'

# A basic model for a sinatra/mysql setup.
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

  # escape SQL-interfering strings
  def self.escape(str)
    Mysql2::Client.escape(str)
  end

  # escape html-interfering strings
  def self.sanitize(str)
    Rack::Utils.escape_html(str)
  end
end
