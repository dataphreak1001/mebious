require 'sinatra'
require 'builder'
require 'rack/csrf'
require 'sinatra/cross_origin'
require_relative 'models/posts'
require_relative 'models/bans'
require_relative 'models/api'
require_relative 'utils/Mebious'

$config = "./config.json"
$posts  = Posts.new($config)
$bans   = Bans.new($config)
$api    = API.new($config)

class MebiousApp < Sinatra::Base
  set :allow_origin, :any
  set :allow_methods, [:get, :post, :options]
  set :max_age, "1728000"
  set :expose_headers, ['Content-Type']

  register Sinatra::CrossOrigin

  configure do
    use Rack::Session::Cookie, :secret => "just an example"
    use Rack::Csrf, :raise => true, :skip => ['POST:/api/.*']
  end

  helpers do
    def csrf_tag
      Rack::Csrf.csrf_tag(env)
    end
  end

  # Main page.
  get ('/') {
    @posts = $posts.last(20)
    erb :index
  }

  # Make post
  post ('/posts') {
    ip = Model::to_sha1(request.ip)
    
    if !params.has_key? "text"
      redirect '/'    
    end

    if params["text"].empty?
      redirect '/'
    end

    text = params["text"].strip

    if $posts.duplicate? text
      redirect '/'
    end

    if $bans.banned? ip
      redirect '/'
    end

    $posts.add(text, ip)
    redirect '/'
  }

  # API - Recent Posts
  get ('/posts') {
    cross_origin
    content_type :json
    $posts.last(20).to_a.to_json
  }

  # API - Last n Posts
  get ('/posts/:n') {
    cross_origin
    content_type :json

    n = params[:n].to_i
    if (n > 50 or n < 1)
      redirect '/posts'
    end

    $posts.last(n).to_a.to_json
  }

  # API - Post API
  post ('/api/:key') {
    cross_origin
    content_type :json

    if $api.allowed? params[:key]
      ip = Model::to_sha1(request.ip)

      if !params.include? "text"
        return {"ok" => false, "error" => "No text parameter!"}.to_json
      end

      if params["text"].empty?
        return {"ok" => false, "error" => "Empty text parameter!"}.to_json
      end

      text = params["text"].strip

      if $posts.duplicate? text
        return {"ok" => false, "error" => "Duplicate post!"}.to_json
      end

      if $bans.banned? ip
        return {"ok" => false, "error" => "You're banned!"}.to_json
      end

      $posts.add(text, ip)
      {"ok" => true}.to_json
    else
      {"ok" => false, "error" => "Invalid API key!"}.to_json
    end
  }

  # RSS Feed
  get ('/rss') {
    @posts = $posts.last(20)
    builder :rss
  }
end
