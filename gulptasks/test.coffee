
Q      = require("q")
gulp   = require("gulp")
gutil  = require("gulp-util")
mocha  = require("gulp-mocha")
coffee = require("gulp-coffee")
es     = require("event-stream")

compile = ()->
  d = Q.defer()
  gulp.src( ["./test/**/*.coffee"] )
    .pipe( coffee({bare:true}) ) # Compile coffee
    .pipe( gulp.dest("./test") )
    .on( "end", (()-> console.log("Compile test successfully."); d.resolve()) )
  d.promise

run = ()->
  server  = require("./server")
  browser = require("../test/env/Browser.js")

  try
    zombie = require("zombie")
  catch e
    console.log gutil.colors.bgYellow.black "  Cannot find zombie. Automated test is disabled.  "
    return false

  # Create server
  testserver = server("./src", 3010, false, false)

  d = Q.defer()

  noop = ()->

  browser.launchIDE().then ( response )->
    console.log "\n\n\n[" + gutil.colors.green("Debug @#{(new Date()).toLocaleTimeString()}") + "] Starting tests."

    browser.silent = true

    shutDown = ()->
      # browser.close() will throw error if we stay in our site, because the websocket
      # will still pump in data after the window is closed.
      browser.close()
      testserver.close()
      d.resolve()
      # If test fails, mocha dosn't quit. Cause the process not quiting.
      process.exit()

    gulp.src( ["./test/**/*.js", "!./test/env/Browser.js", "!./test/stack/requireStacks.js"] )
      .pipe mocha({
        reporter : GLOBAL.gulpConfig.testReporter
        timeout  : 300000
      })
      .on "error", ( e )->
        console.log gutil.colors.bgRed.black " Test failed. ", e
        @emit "end"
      .pipe( es.through noop, shutDown )

  , ( error )->
    d.reject( { error : error, msg : "Cannot login the server to test." }  )

  d.promise

module.exports = {
  compile : compile
  run     : run
}
