
Q      = require("q")
gulp   = require("gulp")
gutil  = require("gulp-util")
mocha  = require("gulp-mocha")
coffee = require("gulp-coffee")
should = require("should")
es     = require("event-stream")

server = require("./server")

browser = require("../test/env/Browser.js")

compile = ()->
  d = Q.defer()
  gulp.src( ["./test/**/*.coffee"] )
    .pipe( coffee({bare:true}) ) # Compile coffee
    .pipe( gulp.dest("./test") )
    .on( "end", (()-> console.log("Compile test successfully."); d.resolve()) )
  d.promise

run = ()->
  try
    zombie = require("zombie")
  catch e
    console.log gutil.colors.bgYellow.black "  Cannot find zombie. Automated test is disabled.  "
    return false

  # Create server
  testserver = server("./src", 3010, false, false)

  d = Q.defer()

  noop = ()->

  browser.resources.post 'http://api.xxx.io/session/', {
    body : '{"jsonrpc":"2.0","id":"1","method":"login","params":["test","aaa123aa",{"timezone":8}]}'
  }, (error, response)->
    res  = JSON.parse( response.body.toString() ).result[1]
    browser.setCookie({
      name   : "session_id"
      value  : res.session_id
      maxAge : 3600*24*30
      domain : "ide.xxx.io"
    })
    browser.setCookie({
      name   : "usercode"
      value  : res.username
      maxAge : 3600*24*30
      domain : "ide.xxx.io"
    })
    browser.visit("/").then ()->
      console.log "\n\n\n[Debug]", "Starting tests."
      gulp.src( ["./test/**/*.js", "!./test/env/Browser.js"] )
        .pipe mocha({reporter: GLOBAL.gulpConfig.testReporter})
        .pipe( es.through noop, ()->
          console.log browser
          # browser.close() will throw error if we stay in our site, because the websocket
          # will still pump in data after the window is closed.
          # browser.close()
          testserver.close()
          d.resolve()
        )
        .on "error", ( e )->
          console.log gutil.colors.bgRed.black " Test failed to run. ", e
          d.reject()

  d.promise

module.exports = {
  compile : compile
  run     : run
}
