_ = require "underscore"
express = require "express"
passport = require "passport"
minimatch = require "minimatch"
view = undefined
module.exports = init: (context, callback) ->

  newPost = (res, message) ->
    page req, res, "new",
      message: message
    
  notFound = (res) ->
    res.send "<h1>Page not found.</h1>", 404

  page = (req,res,template,data) ->
    _.defaults data,
      slots: {}

    _.defaults data.slots,
      user: req.user,
      session: req.session

    res.send view.page(template,data)

  configurePassport = ->
    GoogleStrategy = require("passport-google").Strategy
    passport.use new GoogleStrategy(context.settings.google, (identifier, profile, done) ->
      
      user =
        email: profile.emails[0].value
        displayName: profile.displayName

      done null, user
    )

    passport.serializeUser (user,done) ->
      done null, JSON.stringify(user)

    passport.deserializeUser (json,done) ->
      user = JSON.parse(json)
      if user
        done null,user
      else
        done new Error("Bad JSON in seession"), null

    app.use passport.initialize()
    app.use passport.session()

    app.get "/auth/google", passport.authenticate("google")

    app.get "/auth/google/callback", passport.authenticate("google",
      successRedirect: "/"
      failureRedirect: "/"
    )
    app.get "/logout", (req, res) ->
      req.logOut()
      res.redirect "/"

  validPoster = (req, res) ->
    unless req.user
      res.redirect "/auth/google"
      return false
    unless minimatch(req.user.email, context.settings.posters)
      req.session.error = "Sorry, you do not have permission to post to this blog."
      res.redirect "/"
      return false
    true

  app = context.app = express()
  app.use express.bodyParser()

  view = context.view
  context.app.use express.cookieParser()

  connectMongoDb = require("connect-mongodb")
  mongoStore = new connectMongoDb(db: context.mongoConnection)
  context.app.use express.session(
      secret: context.settings.sessionSecret,
      store: mongoStore
    )

  app.use "/static", express.static(__dirname + "/static")
  configurePassport()
  app.get "/", (req, res) ->
    context.db.posts.findAll (err, posts) ->
      if err
        notFound res
        return
      page req,res,"index",
        posts: posts
      

  app.get "/posts/:slug", (req, res) ->
    context.db.posts.findOneBySlug req.params.slug, (err, post) ->
      if err or (not post)
        notFound res
        return
      page req,res,"post",
        post: post
      


  app.get "/new", (req, res) ->
    return unless validPoster(req,res)
    newPost res

  app.post "/new", (req, res) ->
    return  unless validPoster(req, res)
    post = _.pick(req.body, "title", "body")
    context.db.posts.insert post, (err, post) ->
      if err
        newPost res, "Make sure your title is unique."
      else
        res.redirect "/posts/" + post.slug


  app.get "*", (req, res) ->
    notFound res

  callback()
