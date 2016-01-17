require 'yaml'
require 'json'
require 'sqlite3'
require 'digest'

# A basic model for a sinatra/mysql setup.
class Model
  def initialize(config, table)
    config = YAML.load_file config
    
    if !config.include? "driver"
      raise RuntimeError.new("No database driver given!")
    else
      @driver = config["driver"]
    end

    config = config[@driver]

    case @driver 
      when "sqlite"
        @core = SQLite3::Database.new(config['database'])
        @core.results_as_hash = true
      else
        require 'mysql2'
        @core = Mysql2::Client.new(
          :host      => config["host"],
          :username  => config["username"],
          :password  => config["password"],
          :database  => config["database"],
          :reconnect => true
        )
    end

    @table = table
  end

  def query(statement, args)
    case @driver
      when "sqlite"
        @core.execute(statement, args)
      else
        statement = @core.prepare(statement)
        statement.execute(*args).to_a
    end
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
