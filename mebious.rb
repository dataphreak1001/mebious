require 'sinatra'
require "yaml"
require 'builder'
require 'rack/csrf'
require 'sinatra/cross_origin'
require "active_record"
require_relative 'models/posts'
require_relative 'models/bans'
require_relative 'models/api'
require_relative 'utils/Mebious'

begin
  config  = YAML.load_file "config.yml"
  options = config[config["driver"]]
  [Post, API, Ban].map { |klass|
    case config["driver"]
      when "sqlite"
        klass.establish_connection({
          :adapter  => "sqlite3",
          :database => options["database"]
        })
      else
        klass.establish_connection({
          :adapter  => "mysql2",
          :host     => options["host"],
          :username => options["username"],
          :password => options["password"],
          :database => options["database"]
        })
    end
  }
rescue Exception => e
  puts "Error loading configuration."
  exit 1
end

class MebiousApp < Sinatra::Base
  set :allow_origin, :any
  set :allow_methods, [:get, :post, :options]
  set :max_age, "1728000"
  set :expose_headers, ['Content-Type']

  register Sinatra::CrossOrigin

  configure do
    use Rack::Session::Cookie, :secret => "your secret here"
    use Rack::Csrf, :raise => true, :skip => ['POST:/api/.*']
  end

  helpers do
    def csrf_tag
      Rack::Csrf.csrf_tag(env)
    end
  end

  # Main page.
  get ('/') {
    @posts = Post.last(20).to_a
    erb :index
  }

  # Make post
  post ('/posts') {
    ip = Mebious::digest(request.ip)
    
    if !params.has_key? "text"
      redirect '/'    
    end

    if params["text"].empty?
      redirect '/'
    end

    text = params["text"].strip

    if Post.duplicate? text
      redirect '/'
    end

    if Ban.banned? ip
      redirect '/'
    end

    Post.add(text, ip)
    redirect '/'
  }

  # API - Recent Posts
  get ('/posts') {
    cross_origin
    content_type :json
    Post.last(20).to_json
  }

  # API - Last n Posts
  get ('/posts/:n') {
    cross_origin
    content_type :json

    n = params[:n].to_i
    if (n > 50 or n < 1)
      redirect '/posts'
    end

    Post.last(n).to_json
  }

  # API - Post API
  post ('/api/:key') {
    cross_origin
    content_type :json

    if API.allowed? params[:key]
      ip = Mebious::digest(request.ip)

      if !params.include? "text"
        return {"ok" => false, "error" => "No text parameter!"}.to_json
      end

      if params["text"].empty?
        return {"ok" => false, "error" => "Empty text parameter!"}.to_json
      end

      text = params["text"].strip

      if Post.duplicate? text
        return {"ok" => false, "error" => "Duplicate post!"}.to_json
      end

      if Ban.banned? ip
        return {"ok" => false, "error" => "You're banned!"}.to_json
      end

      Post.add(text, ip)
      {"ok" => true}.to_json
    else
      {"ok" => false, "error" => "Invalid API key!"}.to_json
    end
  }

  # RSS Feed
  get ('/rss') {
    @posts = Post.last(20)
    builder :rss
  }
end
