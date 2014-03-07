
cached = require("./cached")
es     = require("event-stream")
vm     = require("vm")

gulp   = require("gulp")
gutil  = require("gulp-util")
coffee = require("gulp-coffee")

buildLangSrc = require("../../../config/lang")

compileTitle = ( extra )->
  title = "[" + gutil.colors.green("Compile @#{(new Date()).toLocaleTimeString()}") + "]"
  if extra
    title += " " + gutil.colors.inverse( extra )
  title

log  = (e)-> console.log e
noop = ()->

module.exports = ( dest = ".", useCache = true )->

  if useCache
    startPipeline = cached( coffee() )
  else
    startPipeline = coffee()

  pipeline = startPipeline.pipe es.through ( file )->

    console.log compileTitle(), "lang-souce.coffee"

    ctx = vm.createContext({module:{}})
    vm.runInContext( file.contents.toString("utf8"), ctx )

    buildLangSrc.run gruntMock, noop, ctx.module.exports
    null

  pipeline.pipe( gulp.dest(dest) )

  gruntMock =
    log  :
      error : log
    file :
      write : ( p1, p2 ) =>
        cwd = process.cwd()
        pipeline.emit "data", new gutil.File({
          cwd      : cwd
          base     : cwd
          path     : p1
          contents : new Buffer( p2 )
        })
        null

  startPipeline
