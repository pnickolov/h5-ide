
util   = require("./util")
cached = require("./cached")
es     = require("event-stream")
vm     = require("vm")

gulp   = require("gulp")
gutil  = require("gulp-util")
coffee = require("gulp-coffee")

buildLangSrc = require("./lang")

module.exports = ( dest = ".", useCache = true, shouldLog = true )->

  if useCache
    startPipeline = cached( coffee() )
  else
    startPipeline = coffee()

  pipeline = startPipeline.pipe es.through ( file )->

    if shouldLog
      console.log util.compileTitle(), "lang-souce.coffee"

    ctx = vm.createContext({module:{}})
    vm.runInContext( file.contents.toString("utf8"), ctx )

    buildLangSrc writeFile, ctx.module.exports
    null

  pipeline.pipe( gulp.dest(dest) )

  writeFile = ( p1, p2 ) ->
    cwd = process.cwd()
    pipeline.emit "data", new gutil.File({
      cwd      : cwd
      base     : cwd
      path     : p1
      contents : new Buffer( p2 )
    })
    null

  startPipeline
