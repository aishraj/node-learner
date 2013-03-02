_ = require "underscore"
express = require "express"
passport = require "passport"
minimatch = require "minimatch"
view = undefined
module.exports = init: (context, callback) ->

  newPost = (res, message) ->
    res.send view.page("new",
      message: message
    )

  notFound = (res) ->
    res.send "<h1>Page not found.</h1>", 404

  configurePassport ->
    GoogleStrategy = passport = require 'passport-google'.Strategy
    passport.use new GoogleStrategy(context.settings.google, (identifier, profile, done) ->
        user = 
          email: profile.emails[0].value
          displayName = profile.displayName

        done null,user
      )

  app = context.app = express()
  app.use express.bodyParser()

  view = context.view
  context.app.use express.cookieparser()
  context.app.use express.session(
      secret: context.settings.sessionSecret
    )

  app.use "/static", express.static(__dirname + "/static")
  configurePassport()
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

  callback()
