# ejs as we use it here is: https://github.com/visionmedia/ejs
# not the older version in google code, which is rather different
ejs = require "ejs"
_ = require "underscore"
fs = require "fs"
options = undefined
templates = {}
module.exports = view =
  init: init = (optionsArg, callback) ->
    options = optionsArg
    throw new Error("options.viewDir is required, please tell me where the views are")  unless options.viewDir
    callback()

  
  # Render a page template nested in the layout, allowing slots 
  # (such as overrides of the page title) to be passed back to the layout.
  # Anything in data.slots is also passed down to any calls to partial().
  # Since data.slots is an object passed by reference, partials can change
  # data.slots.title, etc. and that will be seen by the layout
  page: page = (template, data) ->
    data = {}  unless data
    
    # Defaulting the crumbs slot to an empty array is helpful because
    # it saves having an explicit default for it in every partial
    _.defaults data,
      slots:
        crumbs: []
        title: ""
        bodyClass: ""

    data.slots.body = view.partial(template, data)
    
    # If a partial has already set the 'layout' slot, respect that instead
    # of the default layout name
    _.defaults data.slots,
      layout: "layout"

    
    # ... Or cancel the layout from a partial
    return data.slots.body  if data.slots.layout is false
    view.partial data.slots.layout,
      slots: data.slots


  partial: partial = (template, data) ->
    data = {}  unless data
    
    # Avoid the use of _.defaults when computing the value is expensive;
    # test and make sure it's necessary
    
    # Compile the template if we haven't already
    
    # Synchronous operations are a little outside the node spirit, but reading
    # small files from the filesystem is very fast, and we only do it once per template,
    # after which we have it cached
    templates[template] = ejs.compile(fs.readFileSync(options.viewDir + "/" + template + ".ejs", "utf8"))  unless templates[template]
    
    # Inject a partial() function for rendering another partial inside this one. 
    # All partials get to participate in overriding slots, unless we explicitly pass
    # a different 'slots' object at some level
    unless data.partial
      data.partial = (partial, partialData) ->
        partialData = {}  unless partialData
        _.defaults partialData,
          slots: data.slots

        view.partial partial, partialData
    
    # Create a slot context if we don't have one already from
    # the call we're nested in. Inject underscore so we can use
    # JS responsibly in templates
    _.defaults data,
      slots: {}
      _: _

    
    # Render the template
    templates[template] data
