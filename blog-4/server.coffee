setupDb = (callback) ->
  context.db = require "./db"
  context.db.init context, callback

setupView = (callback) ->
  context.view = require "./view"
  context.view.init
    viewDir: __dirname + "/views"
  , callback

setupApp = (callback) ->
  context.app = require "./app"
  context.app.init context, callback


listen = (callback) ->
  context.app.listen context.settings.http.port
  callback null

ready = (err) ->
  throw err  if err
  console.log "Ready and listening at http://localhost:" + context.settings.http.port
  
async = require "async"
context = {}
context.settings = require "./settings"
async.series [setupDb, setupView, setupApp, listen], ready
