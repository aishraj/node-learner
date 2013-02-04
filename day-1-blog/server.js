var http = require('http');

var blog_posts = {
    '/hello-world' : {
        title: 'Hello World!',
        body: 'Hello World. This is the first page saying hello to you.',
    },
    '/hello-again' : {
        title: 'Hello Again',
        body: 'This is once again the blog greeting you with a Hello',
    },
    '/answer-to-everything' : {
        title: 'Life Universe and Everything',
        body: 'All I want to say is 42',
    }
};

var server = http.createServer(function(req,res) {
    if (req.url === '/')
    {
        getIndex();
    }
    else if (blog_posts[req.url])
    {
        post(req.url);
    }
    else 
    {
        pageNotFound();
    }

    function getIndex()
    {
        var s = "<title> Home Page of My Test Blog </title>\n";
        s += "<h1> My Test Blog </h1>\n";
        s += "<ul>\n";
        for ( var itemName in blog_posts )
        {
            var post = blog_posts[itemName];
             s += '<li><a href="' + itemName + '">' + post.title + '</a></li>' + "\n";
        }
        s += "</ul>\n";
        sendBody(s);
    }
    
    function post(url)
    {
        var post = blog_posts[url];
        var s = "<title>" + post.title + "</title>\n";
        s += "<h1>My Blog</h1>\n";
        s += "<h2>" + post.title + "</h2>\n";
        s += post.body;
        sendBody(s);
    }

    function sendBody(s)
    {
        console.log('Page Found');
        res.writeHead(200, {'Content-Type': 'text/html'});
        res.end(s);
    }

    function pageNotFound()
    {
        //Please note that modern browsers may request for favicon which may lead to 404 being displayed on the terminal
        //Ignore it for now.
        console.log('Page not found');
        res.writeHead(404,{'Content-Type': 'text/html'});
        res.end('<h1> 404 - Page Not found </h1>');
    }
});

server.listen(8080);
console.log('Server Ready');
