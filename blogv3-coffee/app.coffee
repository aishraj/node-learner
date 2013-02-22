express = require("express")
_ = require("underscore")

#Based on justjs blog. 
#Licensed under MIT License.
#Author is bountell
#This code is here only to fillup the void and act as stub as I learn node.js
module.exports = init: (context, callback) ->
  
  #In order to know the parameters of the POST request.
  #Throw 404
  
  # Deliver a "new post" form when we see /new.
  # POST it right back to the same URL; the next route
  # below will answer 
  
  # Save a new post when we see a POST request
  # for /new (note this is enough to distinguish it
  # from the route above)
  
  # Probably a duplicate slug, ask the user to try again
  # with a more distinctive title. We'll fix this
  # automatically in our next installment
  
  # Send the "new post" page, with an error message if needed
  newPost = (res, message) ->
    s = "<title>New Post</title>\n"
    s += "<h1>My Blog</h1>\n"
    s += "<h2>New Post</h2>\n"
    s += "<h3>" + message + "</h3>\n"  if message
    s += "<form method=\"POST\" action=\"/new\">" + "\n"
    s += "Title: <input name=\"title\" /> <br />" + "\n"
    s += "<textarea name=\"body\"></textarea>" + "\n"
    s += "<input type=\"submit\" value=\"Post It!\" />" + "\n"
    s += "</form>\n"
    res.send s
  
  # The notFound function is factored out so we can call it
  # both from the catch-all, final route and if a URL looks
  # reasonable but doesn't match any actual posts
  notFound = (res) ->
    res.send "<h1>Page not found.</h1>", 404
  app = context.app = express()
  app.use express.bodyParser()
  app.get "/", (req, res) ->
    context.db.posts.findAll (err, posts) ->
      if err
        notFound res
        return
      s = "<title> Blog Title </title>\n"
      s += "<h1> My Blog </h1>\n"
      s += "<p><a href=\"/new\">New Post</a></p>" + "\n"
      s += "<ul>\n"
      for slug of posts
        post = posts[slug]
        s += "<li><a href=\"/posts/" + post.slug + "\">" + post.title + "</a></li>" + "\n"
      s += "</ul>\n"
      res.send s


  app.get "/posts/:slug", (req, res) ->
    context.db.posts.findOneBySlug req.params.slug, (err, post) ->
      if err or (not post)
        notFound res
        return
      s = "<title>" + post.title + "</title>\n"
      s += "<h1><a href='/'>My Blog</a></h1>\n"
      s += "<h2>" + post.title + "</h2>\n"
      s += post.body
      res.send s


  app.get "/new", (req, res) ->
    newPost res

  app.post "/new", (req, res) ->
    post = _.pick(req.body, "title", "body")
    context.db.posts.insert post, (err, post) ->
      if err
        newPost res, "Make sure your title is unique."
      else
        res.redirect "/posts/" + post.slug


  app.get "*", (req, res) ->
    notFound res

  
  # We didn't have to delegate to anything time-consuming, so
  # just invoke our callback now
  callback()
