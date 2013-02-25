_ = require("underscore")
express = require("express")
view = undefined
module.exports = init: (context, callback) ->
  
  # Create an Express app object to add routes to and add
  # it to the context
  
  # The express "body parser" gives us the parameters of a 
  # POST request is a convenient req.body object
  
  # Get the view module from the context
  
  # Serve static files (such as CSS and js) in this folder
  
  # Deliver a list of posts when we see just '/'
  
  # Deliver a specific post when we see /posts/ 
  
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
    res.send view.page("new",
      message: message
    )
  
  # The notFound function is factored out so we can call it
  # both from the catch-all, final route and if a URL looks
  # reasonable but doesn't match any actual posts
  notFound = (res) ->
    res.send "<h1>Page not found.</h1>", 404
  app = context.app = express.createServer()
  app.use express.bodyParser()
  view = context.view
  app.use "/static", express.static(__dirname + "/static")
  app.get "/", (req, res) ->
    context.db.posts.findAll (err, posts) ->
      if err
        notFound res
        return
      res.send view.page("index",
        posts: posts
      )


  app.get "/posts/:slug", (req, res) ->
    context.db.posts.findOneBySlug req.params.slug, (err, post) ->
      if err or (not post)
        notFound res
        return
      res.send view.page("post",
        post: post
      )


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
