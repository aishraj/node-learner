ejs = require "ejs"
_ = require "underscore"
fs = require "fs"

options = {}
templates = {}

module.exports = view =
  init: init = (optionsArg, callback) ->
    options = optionsArg
    throw new Error("options.viewDir is required, please tell me where the views are")  unless options.viewDir
    callback()

  
  page: page = (template, data) ->
    data = {}  unless data
    
    _.defaults data,
      slots:
        crumbs: []
        title: ""
        bodyClass: ""

    data.slots.body = view.partial(template, data)
    
    _.defaults data.slots,
      layout: "layout"

    return data.slots.body  if data.slots.layout is false
    view.partial data.slots.layout,
      slots: data.slots


  partial: partial = (template, data) ->
    data = {}  unless data
    
    templateName = fs.readFileSync options.viewDir + "/" + template + ".ejs", "utf8"
    templates[template] = ejs.compile templateName unless templates[template]
    
    unless data.partial
      data.partial = (partial, partialData) ->
        partialData = {}  unless partialData
        _.defaults partialData,
          slots: data.slots

        view.partial partial, partialData
    
    _.defaults data,
      slots: {}
      _: _

    templates[template] data
