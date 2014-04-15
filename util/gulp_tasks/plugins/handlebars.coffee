
es         = require("event-stream")
handlebars = require("handlebars")
path       = require("path")
fs         = require("fs")

gutil      = require("gulp-util")
coffee     = require("gulp-coffee")

util       = require("./util")

DefaultKnownHelpers =
  is_service_error : true
  is_unmanaged     : true
  city_code        : true
  city_area        : true
  convert_string   : true
  is_vpc_disabled  : true
  vpc_list         : true
  vpc_sub_item     : true

HandlebarsOptions =
  knownHelpersOnly : true
  knownHelpers : {}

HasRead = false

IgnoreSyntax = new Buffer("<!DOCTYPE HTML>")

readHelperFile = ()->
  if HasRead then return

  file = fs.readFileSync( "./src/lib/handlebarhelpers.coffee" )
  pipeline = es.through (f)->
  pipeline.pipe( coffee() ).pipe es.through ( f )->
    helpers = {}
    f.contents.toString("utf8").replace /Handlebars.registerHelper\(('|")([^'"']+?)('|")/g, ( match, p1, p2, p3 )->
      helpers[ p2 ] = true
      match

    HandlebarsOptions.knownHelpers[i] = true for i of DefaultKnownHelpers
    HandlebarsOptions.knownHelpers[i] = true for i of helpers

    if GLOBAL.gulpConfig.verbose
      console.log "[Updated HandlebarsHelpers]", HandlebarsOptions.knownHelpers
    null

  pipeline.emit "data", {
    path     : "./src/lib/handlebarhelpers.coffee"
    contents : file
    isNull   : ()-> false
    isStream : ()-> false
  }

  HasRead = true
  null


compile = ( file )->
  # Ignored compiling if the file has <!DOCTYPE html>
  ignored = true
  for i, idx in IgnoreSyntax
    if file.contents[idx] isnt i
      ignored = false
      break
  if ignored
    if @shouldLog
      console.log "[Handlebars Ignored]", file.relative
    @emit "data", file
    return

  # Compile hanldebars
  readHelperFile()

  if path.extname(file.path) is ".partials"
    compilePartials( file, @shouldLog )
  else
    compileHbs( file, @shouldLog )

  @emit "data", file
  null

tryCompile = ( data, file )->
  try
    data = data.replace(/^\s+|\s+$/g, '')
    result = handlebars.precompile( data, HandlebarsOptions )
  catch e
    console.log gutil.colors.red.bold("\n[TplError]"), file.relative
    console.log e.message + "\n"

    util.notify "Error occur when compiling " + file.relative

    return ""

  result

compilePartials = ( file, shouldLog )->
  content = file.contents.toString("utf8").replace(/\r\n/g, "\n")
  data = content.split(/<!--\s*\{\{\s*(.*)\s*\}\}\s*-->\n/ig)

  newData = ""
  namespace = {}

  i = 1
  while i < data.length
    result = tryCompile( data[i+1], file )
    if not result
      newData = ""
      break


    newData += "__TEMPLATE__ =" + result + ";\nTEMPLATE.#{data[i]}=Handlebars.template(__TEMPLATE__);\n\n\n"

    namespaces = data[i].split(".")
    space = namespace

    for n, idx in namespaces
      if idx < namespaces.length - 1
        if not space[n] then space[n] = {}
        space = space[n]

    i += 2

  if newData and shouldLog
    console.log util.compileTitle(), file.relative

  newData = "define(['handlebars'], function(Handlebars){ var __TEMPLATE__, TEMPLATE=" + JSON.stringify(namespace) + ";\n\n" + newData + "return TEMPLATE; });"

  file.contents = new Buffer( newData, "utf8" )
  file.path = gutil.replaceExtension(file.path, ".js")
  null

compileHbs = ( file, shouldLog )->
  newData = tryCompile file.contents.toString("utf8"), file

  if newData and shouldLog
    console.log util.compileTitle(), file.relative

  newData = "define(['handlebars'], function(Handlebars){ var TEMPLATE = " + newData + "; return Handlebars.template(TEMPLATE); });"

  file.contents = new Buffer( newData, "utf8" )
  file.path = gutil.replaceExtension(file.path, ".js")
  null

compiler = ( shouldLog = true )->
  pipe = es.through( compile )
  pipe.shouldLog = shouldLog
  pipe

compiler.reloadConfig = ()->
  HasRead = false
  HandlebarsOptions.knownHelpers = {}
  null

module.exports = compiler
