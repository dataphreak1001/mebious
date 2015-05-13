require 'sinatra'

$pages = {
  "/" => :index
}

# Simple views.
for page,sym in $pages
  get ("/#{page}") {
    erb sym
  }
end
