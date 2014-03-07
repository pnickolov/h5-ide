
es         = require("event-stream")
handlebars = require("handlebars")
path       = require("path")
gutil      = require("gulp-util")

HandlebarsOptions =
  knownHelpersOnly : true
  knownHelpers :
    i18n   : true
    ifCond : true

compile = ( file )->
  if path.extname(file.path) is ".partials"
    compilePartials( file )
  else
    compileHbs( file )

  @emit "data", file
  null

compilePartials = ( file )->
  content = file.contents.toString("utf8")
  data = content.split(/\<!-- (.*) --\>/ig)

  newData = ""
  namespace = {}

  i = 1
  while i < data.length
    newData += "TEMPLATE.#{data[i]}=" + handlebars.precompile( data[i+1], HandlebarsOptions ) + ";\n\n"

    namespaces = data[i].split(".")
    space = namespace

    for n, idx in namespaces
      if idx < namespaces.length - 1
        if not space[n] then space[n] = {}
        space = space[n]

    i += 2

  newData = "define(['handlebars'], function(Handlebars){ var TEMPLATE=" + JSON.stringify(namespace) + ";\n\n" + newData + "return TEMPLATE; });"

  file.contents = new Buffer( newData, "utf8" )
  file.path = gutil.replaceExtension(file.path, ".js")
  null

compileHbs = ( file )->
  newData = handlebars.precompile file.contents.toString("utf8"), HandlebarsOptions
  newData = "define(['handlebars'], function(Handlebars){ var TEMPLATE = " + newData + "; return TEMPLATE; });"

  file.contents = new Buffer( newData, "utf8" )
  file.path = gutil.replaceExtension(file.path, ".js")
  null

module.exports = ()->
  es.through( compile )
