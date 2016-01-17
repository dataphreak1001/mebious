require 'sqlite3'
require 'json'
require 'digest'

# A basic model for a sinatra/mysql setup.
class Model
  def initialize(config, table)
    data = File.read(config)
    data = JSON.parse(data)
    @core = SQLite3::Database.new(data['database']) 
    @core.results_as_hash = true

    @table = table
  end

  def query(*args)
    @core.execute(*args)
  end

  # escape SQL-interfering strings
  def self.escape(str)
    SQLite3::Database.quote(str)
  end

  # escape html-interfering strings
  def self.sanitize(str)
    Rack::Utils.escape_html(str)
  end

  def self.to_sha1(str)
    Digest::SHA1.hexdigest(str)
  end
end
