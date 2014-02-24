
gulp   = require("gulp")
gutil  = require("gulp-util")
path   = require("path")
Buffer = require('buffer').Buffer
es     = require("event-stream")
Q      = require("q")

walk   = require("walkdir")
tinylr = require("tiny-lr")

coffee     = require("gulp-coffee")
coffeelint = require("gulp-coffeelint")
jshint     = require("gulp-jshint")
gulpif     = require("gulp-if")

buildLangSrc = require("../../config/lang")


# Configs
coffeelintOptions =
  indentation     : { level : "ignore" }
  no_tabs         : { level : "ignore" }
  max_line_length : { level : "ignore" }


compileIgnorePath = /.src.(test|vender|ui)/
compileCoffeeOnlyRegex = /.src.(service|model)/

verbose = true

lrServer = null

Helper =
  shouldLintCoffee : (f)-> not f.path.match compileCoffeeOnlyRegex
  endsWith : ( string, pattern )->
    if string.length < pattern.length then return false

    idx      = 0
    startIdx = string.length - pattern.length

    while idx < pattern.length
      if string[ startIdx + idx ] isnt pattern[ idx ]
        return false
      ++idx

    true
  createLrServer : ()->
    if lrServer then return

    # Start LiveReload Server
    gutil.log gutil.colors.bgBlue(" Starting livereload server... ")

    lrServer = tinylr()
    # Better error output
    # lrServer.server.removeAllListeners 'error'
    # lrServer.server.on "error", (e)->
    #   if e.code isnt "EADDRINUSE" then return
    #   console.error('[LR Error] Cannot start livereload server. You already have a server listening on %s', lrServer.port)
    #   lrServer = null

    lrServer.listen 35729, ( err )->
      if err
        gutil.log "[LR Error]", "Cannot start livereload server"
        lrServer = null
      null

    null

  log  : (e)-> console.log e
  noop : ()->


StreamFuncs =
  lintReporter : require('./reporter')

  throughLiveReload : ()->
    es.through ( file )->
      if lrServer
        if verbose then console.log "[LiveReload]", file.replace( process.cwd(), "." )
        lrServer.changed {
          body : { files : [ filePath ] }
        }

      @emit 'data', file
      null

  coffeeErrorPrinter : ( error )->
    console.log gutil.colors.red.bold("\n[CoffeeError]"), error.message.replace( process.cwd(), "." )
    null

  throughLangSrc : ()->
    pipeline = es.through ( file )->
      console.log "[Compiling] lang-souce.coffee"
      buildLangSrc.run gruntMock, Helper.noop
      null

    gruntMock =
      log  :
        error : Helper.log
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

    pipeline


setupCompileStream = ( stream )->

  # Branch Used to handle asset files ( image / css / fonts / etc. )
  assetBranch = StreamFuncs.throughLiveReload()

  # Branch Used to handle lang-source.js
  langSrcBranch = StreamFuncs.throughLangSrc()
  langSrcBranch.pipe( gulp.dest(".") )

  # Branch Used to handle coffee files
  coffeeBranch = gulpif( Helper.shouldLintCoffee, coffeelint( undefined, coffeelintOptions) )

  # Compile
  coffeeCompile = coffeeBranch.pipe( coffee({bare:true}) )

  coffeeCompile
    # Log
    .pipe( es.through ( f )->
      console.log "[Compile] #{f.relative}"
      @emit "data", f
    )
    # Jshint and report
    .pipe( gulpif Helper.shouldLintCoffee, jshint() )
    .pipe( gulpif Helper.shouldLintCoffee, StreamFuncs.lintReporter() )
    # Save
    .pipe( gulp.dest(".") )

  # calling pipe will add and error listener to the pipeline.
  # Making the pipeline stop after an error occur.
  # But I want the coffee pipeline still works even after compilation fails.
  coffeeCompile.removeAllListeners("error")
  coffeeCompile.on("error", StreamFuncs.coffeeErrorPrinter)


  # Setup compile branch
  stream.pipe( gulpif /lang-source\.coffee/, langSrcBranch, true )
        .pipe( gulpif /src.assets/, assetBranch,  true )
        .pipe( gulpif /\.coffee$/,  coffeeBranch, true )


# Tasks
watch = ()->

  # Helper.createLrServer()

  # Watch files
  # gutil.log gutil.colors.bgBlue(" Watching file changes... ")

  # chokidar = require("chokidar")

  # watcher = chokidar.watch "./src", {
  #   usePolling    : false
  #   useFsEvents   : true
  #   ignoreInitial : true
  #   ignored       : /([\/\\]\.)|src.(test|vender)/
  # }

  # changeHandler = ( path )->
  #   if verbose then console.log "[Change]", path

  #   fileTaskDistribute( path )
  #   null

  # watcher.on "add",    changeHandler
  # watcher.on "change", changeHandler
  # null


compileDev = ( allCoffee )->
  if allCoffee
    path = ["src/**/*.coffee", "!src/test/**/*" ]
  else
    path = ["src/**/*.coffee", "!src/test/**/*", "!src/service/**/*", "!src/model/**/*" ]

  deferred = Q.defer()

  setupCompileStream( gulp.src path, {cwdbase:true} ).on "end", ()->
    deferred.resolve()

  deferred.promise



module.exports =
  watch      : watch
  compileDev : compileDev
