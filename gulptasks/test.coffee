
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
    .pipe( coffee() ) # Compile coffee
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

  return browser.resources.post 'http://api.xxx.io/session/', {
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

  # return browser.visit("http://ide.xxx.io/login").then ()->
  #   # login
  #   console.log( browser.window.location.href )
  #   browser.fill("#login-user", "test").fill("#login-password", "aaa123aa").pressButton("#login-btn")
  # .then ()->
  #   console.log( browser.getCookie("session_id") )
  #   console.log( browser.window.location.href )

  # # Start test with zombie
  # logTask "Starting automated test"

  # d = Q.defer()
  # p = ["./test/**/*.js", "!./test/Browser.js"]

  # ###
  # console.log "Loading IDE in Zombie."

  # # Create a zombie browser
  # Browser = require("../../../test/env/Browser")
  # Browser.globalBrowser.visit("http://127.0.0.1:3010").then ()->

  #   gulp.src(p)
  #     .pipe mocha({reporter: GLOBAL.gulpConfig.testReporter})
  #     .pipe es.through ()->
  #       # Don't know why, but we need a pipe here,
  #       # so that the `end` event will be delivered.
  #       true
  #     .on "end", ()-> d.resolve()
  #     .on "error", ()->
  #       console.log gutil.colors.bgRed.black "  Deploy aborted, due to test failure.  "
  #       d.reject()
  #   null
  # .fail (error)->
  #   console.log gutil.colors.bgRed.black "  Deploy aborted, due to zombie fails to run.  "
  #   d.reject()
  # ###

  # gulp.src(p)
  #   .pipe mocha({reporter: GLOBAL.gulpConfig.testReporter})
  #   .pipe es.through ()-> true
  #   .on "end", ()-> d.resolve()
  #   .on "error", ()->
  #     console.log gutil.colors.bgRed.black "  Deploy aborted, due to test failure.  "
  #     d.reject()

  # d.promise

  #   ( url )->
  # try
  #   zombie = require("zombie")
  # catch e
  #   console.log gutil.colors.bgYellow.black "  Cannot find zombie. Automated test is disabled.  "
  #   return false

  # compileTestCoffee().then( prepare ).then( runTest )

module.exports = {
  compile : compile
  run     : run
}
