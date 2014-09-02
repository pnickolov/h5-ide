
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
langemitError = pipeline = langDest = langShouldLog = null
compiled = false

compileImmediately = () -> compiled = true

langCache = ( dest = ".", useCache = true, shouldLog = true, emitError = false )->
  if useCache
    startPipeline = cached( coffee() )
  else
    startPipeline = coffee()

  cacheForLang = {}
  langDest = dest
  langemitError = emitError
  langShouldLog = shouldLog

  pipeline = startPipeline.pipe es.through ( file )->

    ctx = vm.createContext({module:{}})
    try
      vm.runInContext( file.contents.toString("utf8"), ctx )
      deepExtend cacheForLang, ctx.module.exports
    catch e
      console.log e
      console.log gutil.colors.red.bold("\n[LangSrc]"), "lang-source.coffee content is invalid"

    cwd = file.cwd
    base = file.base

    pipeline.setMaxListeners(100)
    pipeline.pipe( gulp.dest(langDest) )

    if compiled then langWrite()

    null


  startPipeline

langWrite = () ->
  writeFile = ( files ) ->
    for file in files
      pipeline.emit "data", new gutil.File({
        cwd      : cwd
        base     : base
        path     : file.path
        contents : new Buffer( file.contents )
      })

    pipeline.emit "end"

    if langShouldLog then console.log util.compileTitle(), "Lang-file Compiled Done"

    null

  if buildLangSrc(writeFile, cacheForLang) is false and langemitError
    pipeline.emit "error", "LangSrc build failure"

  compiled = true

  null

module.exports = {
  langCache         : langCache
  langWrite         : langWrite
  compileImmediately: compileImmediately
}