
Q      = require("q")
gulp   = require("gulp")
gutil  = require("gulp-util")
mocha  = require("gulp-mocha")
coffee = require("gulp-coffee")
should = require("should")

es = require("event-stream")

confCompile = require("./conditional")

compileTestCoffee = ( debugMode )->
  if GLOBAL.gulpConfig.verbose then console.log "Compiling Testcase"

  d = Q.defer()
  pipe = gulp.src( ["./test/**/*.coffee"] )
    .pipe( confCompile( true ) ) # Remove ### env:dev ###
    .pipe( coffee() ) # Compile coffee
    .pipe( gulp.dest("./test") )
    .on( "end", ()-> d.resolve() )
  d.promise

runTest = ()->
  d = Q.defer()
  p = ["./test/**/*.js", "!./test/Browser.js"]

  ###
  console.log "Loading IDE in Zombie."

  # Create a zombie browser
  Browser = require("../../../test/env/Browser")
  Browser.globalBrowser.visit("http://127.0.0.1:3010").then ()->

    gulp.src(p)
      .pipe mocha({reporter: GLOBAL.gulpConfig.testReporter})
      .pipe es.through ()->
        # Don't know why, but we need a pipe here,
        # so that the `end` event will be delivered.
        true
      .on "end", ()-> d.resolve()
      .on "error", ()->
        console.log gutil.colors.bgRed.black "  Deploy aborted, due to test failure.  "
        d.reject()
    null
  .fail (error)->
    console.log gutil.colors.bgRed.black "  Deploy aborted, due to zombie fails to run.  "
    d.reject()
  ###

  gulp.src(p)
    .pipe mocha({reporter: GLOBAL.gulpConfig.testReporter})
    .pipe es.through ()-> true
    .on "end", ()-> d.resolve()
    .on "error", ()->
      console.log gutil.colors.bgRed.black "  Deploy aborted, due to test failure.  "
      d.reject()

  d.promise

module.exports = ( url )->
  try
    zombie = require("zombie")
  catch e
    console.log gutil.colors.bgYellow.black "  Cannot find zombie. Automated test is not disabled.  "
    return false

  compileTestCoffee().then runTest
