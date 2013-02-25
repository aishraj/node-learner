
mongo = require("mongodb")


db = {}
postCollection = {}
context = {}
settings = {}

module.exports = db =
  
  init: (contextArg, callback) ->
    context = contextArg
    settings = context.settings
    
    dbConnection = new mongo.Db(settings.db.name, new mongo.Server(settings.db.host, settings.db.port, {}), {safe:true})
    
    dbConnection.open (err) ->
      
      callback err  if err
      
      postCollection = dbConnection.collection("post")
      
      postCollection.ensureIndex "slug",
        unique: true
      , (err, indexName) ->
        
        callback err

  posts:
    
    findAll: (callback) ->
      postCollection.find().sort(created: -1).toArray (err, posts) ->
        callback err, posts

    findOneBySlug: (slug, callback) ->
      postCollection.findOne
        slug: slug
      , (err, post) ->
        callback err, post


    
    insert: (post, callback) ->
      
      post.slug = db.slugify(post.title)
      
      post.created = new Date()
      
      postCollection.insert post,
        safe: true
      , (err) ->
        if err
          callback err
        else
          callback err, post


  
  slugify: (s) ->
    
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
