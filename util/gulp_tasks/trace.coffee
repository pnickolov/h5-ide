
# A task used to trace module dependency

Q    = require("q")
gulp = require("gulp")

rjsconfig = require("./plugins/rjsconfig")
requirejs = require("./plugins/r")
util      = require("./plugins/util")

copyJs = ()->
  p = ["./src/**/*.js", "!./src/test/**/*"]

  d = Q.defer()
  gulp.src( p ).pipe( gulp.dest("./build") ).on( "end", ()-> d.resolve() )
  d.promise

module.exports = ()->

  copyJs().then ()->

    d = Q.defer()
    requirejs.optimize(
      rjsconfig( true, "./trace", true )
    , (buildres)->
      console.log( "Module Dependencies:")
      console.log( buildres )
      util.deleteFolderRecursive( process.cwd() + "/trace" )
      util.deleteFolderRecursive( process.cwd() + "/build" )
      d.resolve()
    , (err)->
      console.log err
      d.reject()
    )

    d.promise
