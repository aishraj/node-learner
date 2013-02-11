var async = require('async');

var context = {};
context.settings = require('./settings');

async.series([setupDb, setupApp, listen], ready);

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
