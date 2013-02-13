var mongo = require('mongodb');

//These are private to this file.
var db;
var postsCollection;
var context;
var settings;

module.exports = db = {
    //Initialze then call the callback on error or sucess 
    init: function(contextArg, callback) {
        context = contextArg;
        settings = context.settings;

        var dbConnection = new mongo.Db(settings.db.name, new mongo.Server(settings.db.host,settings.db.port,{}),{});
        dbConnection.open(function(err) {
            if (err) {
                callback(err);
            }
            //Get the collection (ie the table in sql) from mongo
            postsCollection = dbConnection.collection('post');
            postsCollection.ensureIndex("slug", { unique: true }, function(err,indexName) {
                //If an error occurs or the fuction passes
                callback(err);
            });
        });
    },
    posts: {
        findAll: function(callback) {
            postsCollection.find().sort({created: -1}).toArray(function(err, posts) {
                callback(err, posts);
            });
        },
        findOneBySlug: function(slug,callback) {
            postsCollection.findOne({slug: slug}, function(err, post) {
                callback(err);
            });
        },
        insert: function(post,callback) {
            post.slug = db.slugify(post.title);
            post.created = new Date();
            postsCollection.insert(post, {safe: true}, function(err) {
                if (err) 
                {
                    callback(err);
                }
                else {
                    callback(err, post);
                }
            });
        }
    },
    slugify: function(s) {
        //This function cleans up the input to create a slug URL for the blog post
        //This part is copied verbatim from http://justjs.com/posts/models-mongodb-and-modules-oh-my
        //Just part of moving on fast. Need to use xregexp and include date to make it more robust
        

        // Everything not a letter or number becomes a dash
        s = s.replace(/[^A-Za-z0-9]/g, '-');
        // Consecutive dashes become one dash
        s = s.replace(/\-+/g, '-');
        // Leading dashes go away
        s = s.replace(/^\-/, '');
        // Trailing dashes go away
        s = s.replace(/\-$/, '');
        // If the string is empty, supply something so that routes still match
        if (!s.length)
        {
            s = 'none';
        }
        return s.toLowerCase();
    }
};
