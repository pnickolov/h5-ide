
util   = require("./util")
cached = require("./cached")
es     = require("event-stream")
vm     = require("vm")

gulp   = require("gulp")
gutil  = require("gulp-util")
coffee = require("gulp-coffee")

buildLangSrc = require("./lang")

module.exports = ( dest = ".", useCache = true, shouldLog = true, emitError = false )->

  if useCache
    startPipeline = cached( coffee() )
  else
    startPipeline = coffee()

  pipeline = startPipeline.pipe es.through ( file )->

    if shouldLog
      console.log util.compileTitle(), "lang-souce.coffee"

    ctx = vm.createContext({module:{}})
    try
      vm.runInContext( file.contents.toString("utf8"), ctx )
    catch e
      console.log gutil.colors.red.bold("\n[LangSrc]"), "lang-source.coffee content is invalid"

    writeFile = ( p1, p2 ) ->
      cwd = process.cwd()
      pipeline.emit "data", new gutil.File({
        cwd      : file.cwd
        base     : file.base
        path     : p1
        contents : new Buffer( p2 )
      })
      null

    if buildLangSrc(writeFile, ctx.module.exports) is false and emitError
      pipeline.emit "error", "LangSrc build failure"
    null

  pipeline.pipe( gulp.dest(dest) )


  startPipeline
