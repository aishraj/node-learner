# Settings for our app. The 'require' call in server.js returns
# whatever we assign to 'module.exports' in this file
module.exports =
  
  # MongoDB database settings
  db:
    host: "127.0.0.1"
    port: 27017
    name: "justjsblogdemo"

  
  # Port for the webserver to listen on
  http:
    port: 3000

  sessionSecret: '0AAE34BC8DD'

  google:
  	returnURL: 'http://localhost:3000/auth/google/callback',
  	realm: 'http://localhost:3000/'

  posters: 'dahalaishraj+gitcheck@gmail.com'
