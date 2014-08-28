
util        = require("./util")
cached      = require("./cached")
es          = require("event-stream")
vm          = require("vm")
deepExtend  = require('deep-extend')

gulp        = require("gulp")
gutil       = require("gulp-util")
coffee      = require("gulp-coffee")


buildLangSrc = require("./lang")
cacheForLang = {}
cwd = base = ""
langemitError = pipeline = langDest = null
compiled = false

langCache = ( dest = ".", useCache = true, shouldLog = true, emitError = false )->
  if useCache
    startPipeline = cached( coffee() )
  else
    startPipeline = coffee()

  cacheForLang = {}
  langDest = dest
  langemitError = emitError

  pipeline = startPipeline.pipe es.through ( file )->

    ctx = vm.createContext({module:{}})
    try
      vm.runInContext( file.contents.toString("utf8"), ctx )
      deepExtend cacheForLang, ctx.module.exports
    catch e
      console.log e
      console.log gutil.colors.red.bold("\n[LangSrc]"), "lang-source.coffee content is invalid"

    if shouldLog
      console.log util.compileTitle(), file.relative

    cwd = file.cwd
    base = file.base

    pipeline.pipe( gulp.dest(langDest) )

    if compiled then langWrite()

    null


  startPipeline

langWrite = () ->
  writeFile = ( p1, p2 ) ->
    pipeline.emit "data", new gutil.File({
      cwd      : cwd
      base     : base
      path     : p1
      contents : new Buffer( p2 )
    })
    compiled = true
    null

  if buildLangSrc(writeFile, cacheForLang) is false and langemitError
    pipeline.emit "error", "LangSrc build failure"

module.exports = {
  langCache: langCache
  langWrite: langWrite
}