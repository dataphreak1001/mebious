mebious.wired
=============

A clone of [Mebby](http://mebious.co.uk) written in Ruby using the Sinatra framework.

Developed on 2.2.2, may work with earlier versions.

### Overview of the Data API

-----

`mebious.wired` uses a RESTful API to facilitate the development of
third party interfaces with read/write access to the central database.

Currently, the API looks like this:

`GET /posts` -> Returns a JSON array of objects representing the last 20 posts.

`GET /posts/n` (n = Integer > 0 and < 100) -> Returns a JSON array of objects representing the last `n` posts.

`POST /api/key` (key = API key) -> Makes a post where the text body is the POST field "text", returns a JSON object of success/error state.

----

# Dependencies
- sinatra
- sqlite3 
- builder
- rack_csrf 
- sinatra-cross_origin
- mysql2 (optional, for mysql support)
