# Settings for our app. The 'require' call in server.js returns
# whatever we assign to 'module.exports' in this file
module.exports =
  
  # MongoDB database settings
  db:
    host: "127.0.0.1"
    port: 27017
    name: "justcoffeeblogdemo"

  
  # Port for the webserver to listen on
  http:
    port: 8080
