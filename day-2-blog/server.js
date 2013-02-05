var express = require('express');

var posts = {
    'hello-world' : {
        title: 'Hello World!',
        body: 'Hello World. This is the first page saying hello to you.',
    },
    'hello-again' : {
        title: 'Hello Again',
        body: 'This is once again the blog greeting you with a Hello',
    },
    'answer-to-everything' : {
        title: 'Life Universe and Everything',
        body: 'All I want to say is 42',
    }
};

var app = express();

app.get('/',function(req,res) {
    var s = "<title> Test Blog </title>\n";
    s += "<h1> Test Blog </h1>\n";
    s += "<ul>\n";
    for (var unique_url in posts) {
        var post = posts[unique_url];
        s += '<li><a href="/posts/' + unique_url + '">' + post.title + '</a></li>' + "\n";
    }
    s += "</ul>\n";
    res.send(s);
});

app.get('/posts/:unique_url',function(req,res) {
    var post = posts[req.params.unique_url];
    if (typeof(post) === 'undefined') {
        notFound(res);
        return;
    }
    var s = "<title>" + post.title + "</title>\n";
    s += "<h1>My Blog</h1>\n";
    s += "<h2>" + post.title + "</h2>\n";
    s += post.body;
    res.send(s);
});

app.get('*', function(req, res) {
  notFound(res);
});

function notFound(res)
{
    res.send('<h1> Page not found </h1>',404);
}

app.listen(8080);
console.log("Server Ready: Waiting for connections");
