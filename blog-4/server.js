var async = require('async');

var context = {}; //Just a wrapper thingy. I've seen these to be pretty handful for JavaScript code.
context.settings = require('./settings');

//This is my first time with Async.
//Using here to do the items in the array to be done in orderly manner one after the other.
async.series([setupDb,setupView, setupApp, listen], ready);

function setupView(callback) {
    context.view = require("./view.js");
    context.view.init({viewDir: __dirname + "/views"}, callback);
}

function setupDb(callback)
{
  // Create our database object
  context.db = require('./db.js');

  // Set up the database connection, create context.db.posts object
  context.db.init(context, callback);
}

function setupApp(callback)
{
  // Create the Express app object and load our routes
  context.app = require('./app.js');
  context.app.init(context, callback);
}

// Listening for connections
function listen(callback)
{
  context.app.listen(context.settings.http.port);
  callback(null);
}

function ready(err)
{
  if (err)
  {
    throw err;
  }
  console.log("Ready and listening at http://localhost:" + context.settings.http.port);
}
