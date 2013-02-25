# We'll be using MongoDB
mongo = require("mongodb")

# These variables are local to this module
db = undefined
postCollection = undefined
context = undefined
settings = undefined
module.exports = db =
  
  # Initialize the module. Invokes callback when ready (or on error)
  init: (contextArg, callback) ->
    context = contextArg
    settings = context.settings
    
    # Open the database connection
    dbConnection = new mongo.Db(settings.db.name, new mongo.Server(settings.db.host, settings.db.port, {}), {})
    
    # db.open doesn't happen right away; we pass a callback function
    # to know when it succeeds
    dbConnection.open (err) ->
      
      # If something goes wrong, call the callback with the error so
      # server.js is aware of the problem
      callback err  if err
      
      # Fetch a MongoDB "collection" (like a table in SQL databases)
      postCollection = dbConnection.collection("post")
      
      # Make sure that collection has a unique index on the "slug" field
      # before we continue. This ensures we don't have two blog posts
      # with the same slug. Once again, we pass a callback function
      postCollection.ensureIndex "slug",
        unique: true
      , (err, indexName) ->
        
        # Now the database is ready to use (or an error has occurred). Invoke the callback
        callback err



  
  # Group the methods relating to posts into a "posts" object, so we
  # can call db.posts.findAll, etc.
  posts:
    
    # Find all posts in reverse order (blog order)
    findAll: (callback) ->
      postCollection.find().sort(created: -1).toArray (err, posts) ->
        callback err, posts


    
    # Fetch a particular post by its slug
    findOneBySlug: (slug, callback) ->
      postCollection.findOne
        slug: slug
      , (err, post) ->
        callback err, post


    
    # Insert a new post
    insert: (post, callback) ->
      
      # Create a reasonable slug from the title
      post.slug = db.slugify(post.title)
      
      # Set the creation date/time
      post.created = new Date()
      
      # Pass the 'safe' option so that we can tell immediately if
      # the insert fails (due to a duplicate slug, for instance)
      postCollection.insert post,
        safe: true
      , (err) ->
        if err
          callback err
        else
          callback err, post


  
  # Create a reasonable slug for use in URLs based on the supplied string
  slugify: (s) ->
    
    # Note: you'll need to use xregexp instead if you need non-Latin character
    # support in slugs
    
    # Everything not a letter or number becomes a dash
    s = s.replace(/[^A-Za-z0-9]/g, "-")
    
    # Consecutive dashes become one dash
    s = s.replace(/\-+/g, "-")
    
    # Leading dashes go away
    s = s.replace(/^\-/, "")
    
    # Trailing dashes go away
    s = s.replace(/\-$/, "")
    
    # If the string is empty, supply something so that routes still match
    s = "none"  unless s.length
    s.toLowerCase()
