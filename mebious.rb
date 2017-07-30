require 'sinatra'
require 'sinatra/flash'
require "yaml"
require 'builder'
require 'rack/csrf'
require 'sinatra/cross_origin'
require "active_record"
require_relative 'models/posts'
require_relative 'models/bans'
require_relative 'models/api'
require_relative 'models/images'
require_relative 'models/filters'
require_relative 'utils/mebious'

begin
  config  = YAML.load_file "config.yml"
  [Post, API, Ban, Image, Filter].map { |klass|
    klass.establish_connection config["database"]
  }
rescue Exception => e
  puts "Error loading configuration."
  puts e
  exit 1
end

class MebiousApp < Sinatra::Base
  set :allow_origin, :any
  set :allow_methods, [:get, :post, :options]
  set :max_age, "1728000"
  set :expose_headers, ['Content-Type']

  register Sinatra::CrossOrigin
  register Sinatra::Flash
  
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
    @posts = Post.last(20).where(:hidden => 0).to_a
    @images = Image.last(10).to_a
    erb :index
  }

  # Make post
  post ('/posts') {
    ip = request.ip

    if !params.has_key? "text"
      flash[:error] = "You failed to include a message!"
      redirect '/'
    end

    if params["text"].empty?
      flash[:error] = "You failed to include a message!"
      redirect '/'
    end

    text = params["text"].strip

    if Post.duplicate? text
      flash[:error] = "Duplicate post detected!"
      redirect '/'
    end

    if Ban.banned? ip
      flash[:error] = "You're banned from posting!"
      redirect '/'
    end

    if Filter.filtered? text
      flash[:error] = "Your post was flagged as spam!"
      redirect '/'
    end

    if Post.spam? text, ip
      flash[:error] = "You're posting way too frequently."
      Ban.create(:ip => ip)
      Post.where(:ip => ip).delete_all # fuck you too
      redirect '/'
    end

    if !text.ascii_only?
      flash[:error] = "Your post contained an invalid character!"
      redirect '/'
    end

    Post.add(text, ip)
    redirect '/'
  }

  # Make image post
  post ('/images') {
    ip = request.ip

    if !params.has_key? "image"
      redirect '/'
    else
      if Ban.banned? ip
        redirect '/'
      end

      if !Image.add(params["image"][:tempfile], ip)
        redirect '/'
      end

      redirect '/'
    end
  }

  get ('/images') {
    cross_origin
    content_type :json
    Image.select("id, url, spawn, checksum").last(20).to_json
  }

  # API - Recent Posts
  get ('/posts') {
    cross_origin
    content_type :json
    Post.select("id, text, spawn, is_admin").last(20).to_json
  }

  # API - Last n Posts
  get ('/posts/:n') {
    cross_origin
    content_type :json

    n = params[:n].to_i
    if (n > 50 or n < 1)
      redirect '/posts'
    end

    Post.select("id, text, spawn, is_admin").last(n).to_json
  }

  # API - Post API
  post ('/api/:key') {
    cross_origin
    content_type :json

    if API.allowed? params[:key]
      ip = request.ip

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

      if Filter.filtered? text
        return {"ok" => false, "error" => "Your post has been detected as spam."}.to_json
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
