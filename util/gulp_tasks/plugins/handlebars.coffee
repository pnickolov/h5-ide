
es         = require("event-stream")
handlebars = require("handlebars")
path       = require("path")
gutil      = require("gulp-util")
util       = require("./util")

HandlebarsOptions =
  knownHelpersOnly : true
  knownHelpers :
    i18n             : true
    ifCond           : true
    nl2br            : true
    emptyStr         : true
    timeStr          : true
    plusone          : true
    tolower          : true
    UTC              : true
    breaklines       : true
    is_service_error : true
    is_unmanaged     : true
    city_code        : true
    city_area        : true
    convert_string   : true
    is_vpc_disabled  : true
    vpc_list         : true
    vpc_sub_item     : true

compile = ( file )->
  if path.extname(file.path) is ".partials"
    compilePartials( file, @shouldLog )
  else
    compileHbs( file, @shouldLog )

  @emit "data", file
  null

tryCompile = ( data, file )->
  try
    result = handlebars.precompile( data, HandlebarsOptions )
  catch e
    console.log gutil.colors.red.bold("\n[TplError]"), file.relative
    console.log e.message + "\n"

    util.notify "Error occur when compiling " + file.relative

    return ""

  result

compilePartials = ( file, shouldLog )->
  content = file.contents.toString("utf8")
  data = content.split(/\<!--\s*\{\{\s*(.*)\s*\}\}\s*--\>\n/ig)

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

module.exports = ( shouldLog = true )->
  pipe = es.through( compile )
  pipe.shouldLog = shouldLog
  pipe
