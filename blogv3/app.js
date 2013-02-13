var express = require("express");
var _ = require("underscore");

//Based on justjs blog. 
//Licensed under MIT License.
//Author is bountell
//This code is here only to fillup the void and act as stub as I learn node.js

module.exports = {
    init: function(context, callback) {
        var app = context.app = express();
        //In order to know the parameters of the POST request.
        app.use(express.bodyParser());

        app.get("/", function(req,res) {
            context.db.posts.findAll(function(err, posts) {
                if (err) {
                    notFound(res); //Throw 404
                    return;
                }
                var s = "<title> Blog Title </title>\n";
                s += "<h1> My Blog </h1>\n";
		        s += '<p><a href="/new">New Post</a></p>' + "\n";
	            s += "<ul>\n";
	            for (var slug in posts)
	            {
	                var post = posts[slug];
	                 s += '<li><a href="/posts/' + post.slug + '">' + post.title + '</a></li>' + "\n";
	            }
	            s += "</ul>\n";
	            res.send(s);
                });
        });

        app.get("/posts/:slug", function(req,res) {
            context.db.posts.findOneBySlug(req.params.slug,function(err,post) {
            if (err || (!post))
            {
             notFound(res);
            return;
            }
            var s = "<title>" + post.title + "</title>\n";
            s += "<h1><a href='/'>My Blog</a></h1>\n";
            s += "<h2>" + post.title + "</h2>\n";
            s += post.body;
            res.send(s);
      });
    });

    // Deliver a "new post" form when we see /new.
    // POST it right back to the same URL; the next route
    // below will answer 
    app.get('/new', function(req, res) {
      newPost(res);
    });

    // Save a new post when we see a POST request
    // for /new (note this is enough to distinguish it
    // from the route above)
    app.post('/new', function(req, res) {
      var post = _.pick(req.body, 'title', 'body');
      context.db.posts.insert(post, function(err, post) {
        if (err)
        {
          // Probably a duplicate slug, ask the user to try again
          // with a more distinctive title. We'll fix this
          // automatically in our next installment
          newPost(res, "Make sure your title is unique.");
        }
        else
        {
          res.redirect('/posts/' + post.slug);
        }
      });
    });

    // Send the "new post" page, with an error message if needed
    function newPost(res, message)
    {
      var s = "<title>New Post</title>\n";
      s += "<h1>My Blog</h1>\n";
      s += "<h2>New Post</h2>\n";
      if (message)
      {
        s += "<h3>" + message + "</h3>\n";
      }
      s += '<form method="POST" action="/new">' + "\n";
      s += 'Title: <input name="title" /> <br />' + "\n";
      s += '<textarea name="body"></textarea>' + "\n";
      s += '<input type="submit" value="Post It!" />' + "\n";
      s += "</form>\n";
      res.send(s);
    }

    app.get('*', function(req, res) {
      notFound(res);
    });

    // The notFound function is factored out so we can call it
    // both from the catch-all, final route and if a URL looks
    // reasonable but doesn't match any actual posts

    function notFound(res)
    {
      res.send('<h1>Page not found.</h1>', 404);
    }

    // We didn't have to delegate to anything time-consuming, so
    // just invoke our callback now
    callback();
  }
};
