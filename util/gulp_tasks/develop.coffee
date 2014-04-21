
gulp   = require("gulp")
gutil  = require("gulp-util")
path   = require("path")
es     = require("event-stream")
Q      = require("q")
fs     = require("fs")
EventEmitter = require("events").EventEmitter

tinylr   = require("tiny-lr")
chokidar = require("chokidar")

coffee     = require("gulp-coffee")
coffeelint = require("gulp-coffeelint")
gulpif     = require("gulp-if")

confCompile  = require("./plugins/conditional")
cached       = require("./plugins/cached")
jshint       = require("./plugins/jshint")
lintReporter = require('./plugins/reporter')
langsrc      = require("./plugins/langsrc")
handlebars   = require("./plugins/handlebars")
globwatcher  = require("./plugins/globwatcher")

util = require("./plugins/util")


# Configs
coffeelintOptions =
  indentation     : { level : "ignore" }
  no_tabs         : { level : "ignore" }
  max_line_length : { level : "ignore" }
  no_debugger     : { level : "ignore" }


compileIgnorePath = /.src.(test|vender|ui)/
compileCoffeeOnlyRegex = /.src.(service|model)/



Helper =
  shouldLintCoffee : (f)-> not f.path.match compileCoffeeOnlyRegex

  compileCompass : ()->
    compassSuccess = true
    gutil.log gutil.colors.bgBlue.white(" Compiling scss... ")
    util.runCommand "compass", ["compile"], { cwd : process.cwd() + "/src/assets" }, {
      onError : (e)->
        if e.code is "ENOENT" and e.errno is "ENOENT" and e.syscall is "spawn"
          compassSuccess = false
          console.log "[" + gutil.colors.yellow("Compass Missing") + "] Scss files are not re-compiled."
        null
      onData : (d)->
        if compassSuccess then process.stdout.write d
    }

  runCompass : ()->
    compassSuccess = false
    gutil.log gutil.colors.bgBlue.white(" Watching scss... ")
    util.runCommand "compass", ["watch"], { cwd : process.cwd() + "/src/assets" }, {
      onError : (e)->
        if e.code is "ENOENT" and e.errno is "ENOENT" and e.syscall is "spawn"
          console.log "[" + gutil.colors.yellow("Compass Missing") + "] Cannot find compass, don't manually edit compressed css."
        null

      onData : (d)->
        if d.indexOf("Compass is polling") > -1
          compassSuccess = true
          return

        if not compassSuccess then return

        process.stdout.write d
        null
    }

  lrServer : undefined
  createLrServer : ()->
    if Helper.lrServer isnt undefined then return

    # Start LiveReload Server
    gutil.log gutil.colors.bgBlue.white(" Starting livereload server... ")

    Helper.lrServer = tinylr()
    # Better error output
    Helper.lrServer.server.removeAllListeners 'error'
    Helper.lrServer.server.on "error", (e)->
      if e.code isnt "EADDRINUSE" then return
      console.error('[LR Error] Cannot start livereload server. You already have a server listening on %s', Helper.lrServer.port)
      Helper.lrServer = null
      null

    Helper.lrServer.listen GLOBAL.gulpConfig.livereloadServerPort, ( err )->
      if err
        gutil.log "[LR Error]", "Cannot start livereload server"
        Helper.lrServer = null
      null

    null

  watchRetry : 0
  watchIsWorking : false
  createWatcher : ()->
    # Watch files
    if GLOBAL.gulpConfig.pollingWatch
      gutil.log gutil.colors.bgBlue.white(" Watching file changes... ") + " [Polling]"

      watcher = new EventEmitter()
      gulp.watch ["./src/**/*.coffee","./src/**/*.html","./src/**/*.partials","./util/gulp_tasks/**/*.partials","./src/assets/**/*", "!src/include/*.html"], ( event )->
        if event.type is "added"
          type = "add"
        else if event.type is "changed"
          type = "change"
        else
          return

        watcher.emit type, event.path
        null
    else
      gutil.log gutil.colors.bgBlue.white(" Watching file changes... ") + " [Native FSevent, vim might not trigger changes]"

      watcher = chokidar.watch ["./src", "./util/gulp_tasks"], {
        usePolling    : false
        useFsEvents   : true
        ignoreInitial : true
        ignored       : /([\/\\]\.)|src.(test|vender)/
      }

      # Native file event doesn't report git action correctly.
      # So we polling watch .git folder
      gitDebounceTimer = null
      compileAfterGitAction = ()->
        console.log "[" + gutil.colors.green("Git Action Detected @#{(new Date()).toLocaleTimeString()}") + "] Ready to re-compile the whole project"
        gitDebounceTimer = null
        compileDev()

      gulpWatch = globwatcher ["./.git/HEAD", "./.git/refs/heads/develop", "./.git/refs/heads/**/*" ], ( event )->
        if gitDebounceTimer is null
          gitDebounceTimer = setTimeout compileAfterGitAction, (GLOBAL.gulpConfig.gitPollingDebounce || 1000)
        null

      gulpWatch.on "error", ( error )-> console.log "[Gulp Watch Git Error]", error

    return watcher


StreamFuncs =

  coffeeErrorPrinter : ( error )->
    console.log gutil.colors.red.bold("\n[CoffeeError]"), error.message.replace( util.cwd, "." )

    util.notify "Error occur when compiling " + error.message.replace( util.cwd, "." ).split(":")[0]
    null

  throughLiveReload : ()->
    es.through ( file )->
      if Helper.lrServer
        Helper.lrServer.changed {
          body : { files : [ file.path ] }
        }
      null

  throughCoffee : ()->

    conditonalLint = gulpif( Helper.shouldLintCoffee, coffeelint( undefined, coffeelintOptions) )

    # Compile
    coffeeBranch  = cached( conditonalLint )

    coffeeCompile = conditonalLint
                    .pipe( confCompile( false ) )
                    .pipe( coffee({sourceMap:GLOBAL.gulpConfig.coffeeSourceMap}) )

    pipeline = coffeeCompile
      # Log
      .pipe( es.through ( f )->
        console.log util.compileTitle( f.extra ), "#{f.relative}"
        @emit "data", f
      )
      # Reload HanldebarsHelper if needed
      .pipe( es.through ( f )->
        if f.path.match /src.lib.handlebarhelpers.js/
          handlebars.reloadConfig()
        @emit "data", f
      )
      # Jshint and report
      .pipe( gulpif Helper.shouldLintCoffee, jshint() )
      .pipe( gulpif Helper.shouldLintCoffee, lintReporter() )
      # Save
      .pipe( gulp.dest(".") )

    if GLOBAL.gulpConfig.reloadJsHtml
      pipeline.pipe StreamFuncs.throughLiveReload()

    # calling pipe will add error listener to the pipeline.
    # Making the pipeline stop after an error occur.
    # But I want the coffee pipeline still works even after compilation fails.
    coffeeCompile.removeAllListeners("error")
    coffeeCompile.on("error", StreamFuncs.coffeeErrorPrinter)

    coffeeBranch

  throughHandlebars : ()->
    pipeline = handlebars()
    pipeline.pipe( gulp.dest(".") )
    cached( pipeline )

  workStream : null
  workEndStream : null
  createStreamObject : ()->
    # Create Work Stream
    if StreamFuncs.workStream then return

    StreamFuncs.workStream    = es.through()
    StreamFuncs.workEndStream = StreamFuncs.setupCompileStream StreamFuncs.workStream
    null

  setupCompileStream : ( stream )->

    # Branch Used to handle asset files ( image / css / fonts / etc. )
    assetBranch = StreamFuncs.throughLiveReload()

    # Branch Used to handle lang-source.js
    langSrcBranch = langsrc()

    # Branch Used to handle coffee files
    coffeeBranch = StreamFuncs.throughCoffee()

    # Branch Used to handle templates
    templateBranch = StreamFuncs.throughHandlebars()

    # Setup compile branch
    langeSrcBranchRegex   = /lang-source\.coffee/
    coffeeBranchRegex     = /\.coffee$/
    templateBranchRegex   = /(\.partials)|(\.html)$/

    if GLOBAL.gulpConfig.reloadJsHtml
      liveReloadBranchRegex = /(src.assets)|(\.js$)/
    else
      liveReloadBranchRegex = /src.assets/

    stream.pipe( gulpif langeSrcBranchRegex,   langSrcBranch,  true )
          .pipe( gulpif templateBranchRegex,   templateBranch, true )
          .pipe( gulpif coffeeBranchRegex,     coffeeBranch,   true )
          .pipe( gulpif liveReloadBranchRegex, assetBranch,    true )



changeHandler = ( path )->
  Helper.watchIsWorking = true

  if not fs.existsSync( path ) then return

  stats = fs.statSync( path )
  # If it's a folder, do nothing
  if stats.isDirectory() then return

  if GLOBAL.gulpConfig.verbose then console.log "[Change]", path

  if path.match /src.assets/
    # No need to read file for assets folder
    StreamFuncs.workStream.emit "data", { path : path }
  else if path.match /src.[^\/]+\.html/
    # Drop the src/*.html here, because it seems like gulpif doesn't
    # handle globs well. Although it claims to support it.
    return
  else
    fs.readFile path, ( err, data )->
      if not data then return

      StreamFuncs.workStream.emit "data", new gutil.File({
        cwd      : util.cwd
        base     : util.cwd
        path     : path
        contents : data
      })
      null
  null

checkWatchHealthy = ( watcher )->
  # Do not ensure watch for polling.
  if GLOBAL.gulpConfig.pollingWatch then return

  # Try to detect if watch is not working
  fs.writeFileSync( "./src/robots.txt", fs.readFileSync("./src/robots.txt") )
  setTimeout ()->
    if not Helper.watchIsWorking
      console.log "[Info]", "Watch is not working. Will retry in 2 seconds."
      util.notify "Watch is not working. Will retry in 2 seconds."
      watcher.removeAllListeners()

      setTimeout (()-> watch()), 2000

  , 500

# Tasks
watch = ()->
  ++Helper.watchRetry
  if Helper.watchRetry > 3
    console.log gutil.colors.red.bold "[Fatal]", "Watch is still not working. Please manually retry."
    util.notify "Watch is still not working. Please manually retry."
    return

  Helper.createLrServer()
  Helper.runCompass()

  StreamFuncs.createStreamObject()

  watcher = Helper.createWatcher()
  watcher.on "add",    changeHandler
  watcher.on "change", changeHandler
  watcher.on "error", (e)-> console.log "[error]", e

  checkWatchHealthy( watcher )
  null


compileDev = ( allCoffee )->
  path = ["src/**/*.coffee", "src/**/*.partials", "src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html" ]
  if not allCoffee and fs.existsSync("./src/service/result_vo.js")
    path.push "!src/service/**/*"
    path.push "!src/model/**/*"

  deferred = Q.defer()

  StreamFuncs.createStreamObject()

  compileStream = gulp.src( path, {cwdbase:true} ).pipe es.through ( f )->
    # Re-pipe the data to the workStream
    StreamFuncs.workStream.emit "data", f
    null

  compileStream.once "end", ()->
    Helper.compileCompass().then ( value )-> deferred.resolve()

  deferred.promise


module.exports =
  watch      : watch
  compileDev : compileDev
