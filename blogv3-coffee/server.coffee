
# Settings for our application. We'll load them from a separate file -
# our first Node module. Use ./ to access a file in the current
# directory. Use them to start building our 'context' object, which
# provides access to all the important stuff we may need throughout
# the application
setupDb = (callback) ->
  
  # Create our database object
  context.db = require "./db"
  
  # Set up the database connection, create context.db.posts object
  context.db.init context, callback
setupApp = (callback) ->
  
  # Create the Express app object and load our routes
  context.app = require "./app"
  context.app.init context, callback

# Ready to roll - start listening for connections
listen = (callback) ->
  context.app.listen context.settings.http.port
  callback null
ready = (err) ->
  throw err  if err
  console.log "Ready and listening at http://localhost:" + context.settings.http.port
async = require "async"
context = {}
context.settings = require("./settings")
async.series [setupDb, setupApp, listen], ready
