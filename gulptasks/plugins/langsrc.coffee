
util        = require("./util")
es          = require("event-stream")
vm          = require("vm")
deepExtend  = require('deep-extend')

gulp        = require("gulp")
gutil       = require("gulp-util")
coffee      = require("gulp-coffee")
Q           = require("q")

coffeelint   = require("gulp-coffeelint")
lintReporter = require('./reporter')

# Configs
DefaultLocale = "en"
LocalePathMapping =
  "en" : "nls/en-us/lang.js"
  "zh" : "nls/zh-cn/lang.js"

LocaleValidator =
  en : ( res )->
    # Copied from old lang.js
    for key, val of res
      if typeof val is "string"
        idx = val.length - 1
        while idx >= 0
          ch = val.charCodeAt(idx)
          if ch <= 0 || ch >= 0xff
            console.log gutil.colors.red.bold("[LangSrc Error]"), "Invalid content for 'en': { #{key} : #{val} }"
            return false
          --idx
      else
        if LocaleValidator.en( val ) is false
          return false

    true

set = ( object, paths, key, val )->
  for p, idx in paths
    object = (object[p] || object[p] = {})

  object[ key ] = val
  return

rPath = []
recursive = ( data, result, lastPath )->

  for key, val of data
    if typeof val is "string"
      # key is like "en", "zh"
      set( result[key] || (result[key] = {}), rPath, lastPath, val || data[DefaultLocale] )
    else
      if lastPath
        rPath.push lastPath
        recursive( val, result, key )
        rPath.length = rPath.length - 1
      else
        recursive( val, result, key )
  return


# Process the source files and write them to disk.
write = ( dest, data )->
  result = {}
  rPath  = []
  recursive( data, result )

  writepipeline = es.through()
  writepipeline.pipe( gulp.dest(dest) )

  for lang, val of result
    validator = LocaleValidator[ lang ]
    if validator and validator( val ) is false
      continue

    path = LocalePathMapping[ lang ]
    if not path
      console.log gutil.colors.yellow.bold("\n[LangSrc]", "Language #{lang}'s path is not specified.")
      continue

    writepipeline.emit "data", new gutil.File({
      path     : path
      relative : path
      contents : new Buffer( "define(" + JSON.stringify(val, undefined, 4) + ")" )
    })

  writepipeline.emit "end"
  return

# Gather source files.
build = ( dest = "./src", shouldLog = true )->

  ctx = vm.createContext({module:{}})

  d = Q.defer()

  result = {}
  p = gulp.src( ["./src/nls/*.coffee"], {cwdbase:true} )

  if shouldLog
    p = p.pipe( coffeelint( undefined, {
      no_tabs         : { level : "ignore" }
      max_line_length : { level : "ignore" }
    }) ).pipe( lintReporter() )

  p.pipe( coffee({bare:true}) ).pipe es.through ( f )->
    try
      vm.runInContext( f.contents.toString("utf8"), ctx )
      deepExtend( result, ctx.module.exports )
    catch e
      console.log gutil.colors.red.bold("\n[LangSrc]"), "Invalid language content @#{f.path}", e

  p.on "end", ()->
    write( dest, result )
    d.resolve()

  d.promise


# Returns a pipeline to be notified when file changes.
pipeline = ()->
  cache = {}

  es.through ( file )->
    if GLOBAL.gulpConfig.enableCache
      utf8Content = file.contents.toString("utf8")
      if cache[ file.path ] is utf8Content
        return

      cache[ file.path ] = utf8Content

    console.log util.compileTitle( "Language" ), file.relative
    build()


module.exports =
  build    : build
  pipeline : pipeline
