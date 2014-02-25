
gulp   = require("gulp")
gutil  = require("gulp-util")
path   = require("path")
Buffer = require('buffer').Buffer
es     = require("event-stream")
Q      = require("q")
fs     = require("fs")

tinylr      = require("tiny-lr")
chokidar    = require("chokidar")
buffertools = require("buffertools")

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
    lrServer.server.removeAllListeners 'error'
    lrServer.server.on "error", (e)->
      if e.code isnt "EADDRINUSE" then return
      console.error('[LR Error] Cannot start livereload server. You already have a server listening on %s', lrServer.port)
      lrServer = null

    lrServer.listen GLOBAL.gulpConfig.livereloadServerPort, ( err )->
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
        lrServer.changed {
          body : { files : [ file.path ] }
        }
      null

  coffeeErrorPrinter : ( error )->
    console.log gutil.colors.red.bold("\n[CoffeeError]"), error.message.replace( process.cwd(), "." )
    null

  throughCoffeeConditionalCompile : ()->
    # This transformer simply replace "### env:prod ### to ### env:prod "
    es.through ( file )->
      buffer = file.contents
      index = 0
      while (index = buffertools.indexOf( buffer, "### env:prod ###", index )) != -1
        if GLOBAL.gulpConfig.verbose then console.log "[EnvProdFound]", file.relative

        buffer[index + 13] = buffer[index + 14] = buffer[index + 15] = 32

        index = buffertools.indexOf( buffer, "### env:prod:end ###", index+16 )
        if index == -1
          console.log "[Missing EnvProdEnd]"
          break
        if GLOBAL.gulpConfig.verbose then console.log "[EnvProdEndFound]", file.relative
        buffer[index + 0] = buffer[index + 1] = buffer[index + 2] = 32
        index += 20

      @emit "data", file
      null

  throughLangSrc : ()->

    pipeline = coffee().pipe es.through ( file )->
      console.log "[Compile] lang-souce.coffee"
      buildLangSrc.run gruntMock, Helper.noop, file.contents
      null

    pipeline.pipe( gulp.dest(".") )

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

  # Branch Used to handle coffee files
  coffeeBranch = gulpif( Helper.shouldLintCoffee, coffeelint( undefined, coffeelintOptions) )

  # Compile
  coffeeCompile = coffeeBranch
                    .pipe( StreamFuncs.throughCoffeeConditionalCompile() )
                    .pipe( coffee({sourceMap:GLOBAL.gulpConfig.coffeeSourceMap}) )

  coffeeCompile
    # Log
    .pipe( es.through ( f )->
      console.log "[Compile] #{f.relative}"
      @emit "data", f
    )
    # Jshint and report
    .pipe( gulpif Helper.shouldLintCoffee, jshint( {lookup:false} ) )
    .pipe( gulpif Helper.shouldLintCoffee, StreamFuncs.lintReporter() )
    # Save
    .pipe( gulp.dest(".") )

  # calling pipe will add and error listener to the pipeline.
  # Making the pipeline stop after an error occur.
  # But I want the coffee pipeline still works even after compilation fails.
  coffeeCompile.removeAllListeners("error")
  coffeeCompile.on("error", StreamFuncs.coffeeErrorPrinter)

  # Setup compile branch
  langeSrcBranchRegex   = /lang-source\.coffee/
  coffeeBranchRegex     = /\.coffee$/

  if GLOBAL.gulpConfig.reloadJsHtml
    liveReloadBranchRegex = /(src.assets)|(\.js$)|(\.html$)/
  else
    liveReloadBranchRegex = /src.assets/

  stream.pipe( gulpif langeSrcBranchRegex, langSrcBranch, true )
        .pipe( gulpif liveReloadBranchRegex, assetBranch,  true )
        .pipe( gulpif coffeeBranchRegex,  coffeeBranch, true )


# Tasks
watch = ()->

  Helper.createLrServer()

  # Watch files
  watcher = chokidar.watch "./src", {
    usePolling    : false
    useFsEvents   : true
    ignoreInitial : false
    ignored       : /([\/\\]\.)|src.(test|vender)/
  }

  cwd         = process.cwd()
  watchStream = es.through()

  setupCompileStream watchStream

  changeHandler = ( path )->
    if not fs.existsSync( path ) then return

    stats = fs.statSync( path )
    # If it's a folder, do nothing
    if stats.isDirectory() then return

    if GLOBAL.gulpConfig.verbose then console.log "[Change]", path

    if path.match /src.assets/
      # No need to read file for assets folder
      watchStream.emit "data", { path : path }
      return


    fs.readFile path, ( err, data )->
      if not data then return

      watchStream.emit "data", new gutil.File({
        cwd      : cwd
        base     : cwd
        path     : path
        contents : data
      })
      null
    null

  # Delay the change handler so that we would ignore the first add event
  # and some change event
  setTimeout ()->
    gutil.log gutil.colors.bgBlue(" Watching file changes... ")
    watcher.on "add",    changeHandler
    watcher.on "change", changeHandler
  , 250
  null


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
