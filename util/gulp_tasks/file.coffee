
gulp  = require("gulp")
gutil = require("gulp-util")
path  = require("path")

walk       = require("walkdir")
coffee     = require("gulp-coffee")
coffeelint = require("gulp-coffeelint")
jshint     = require("gulp-jshint")
reporter   = require('./reporter')
through2   = require("through2")


# Configs
coffeelintOptions =
  indentation     : { level : "ignore" }
  no_tabs         : { level : "ignore" }
  max_line_length : { level : "ignore" }


compileIgnorePath = /.src.(test|vender|ui)/
compileCoffeeOnly = /.src.(service|model)/

verbose = true


fileTaskDistribute = ( file )->
  if endsWith( file, ".coffee" )

    console.log "[Compile] " + file.replace( process.cwd(), "." )

    # Only compile source for service/model
    compileOnly = file.match( compileCoffeeOnly )
    fileDir     = path.dirname(file)

    src = gulp.src( file )

    if not compileOnly
      # CoffeeLint
      src.pipe coffeelint(undefined,coffeelintOptions)

    # Compile Coffee
    src.pipe( coffee({bare:true}).on("error",coffeeErrorPrinter) )
      # Save compiled file
      .pipe( gulp.dest(fileDir) )

    if not compileOnly
      # JsHint and report
      src.pipe( jshint() ).pipe( reporter() )

  else
    # Livereload for css and images


endsWith = ( string, pattern )->
  if string.length < pattern.length then return false

  idx      = 0
  startIdx = string.length - pattern.length

  while idx < pattern.length
    if string[ startIdx + idx ] isnt pattern[ idx ]
      return false
    ++idx

  true

coffeeErrorPrinter = ( error )->
  console.log gutil.colors.red.bold("\n[CoffeeError]"), error.message.replace( process.cwd(), "." )
  @pause()
  null

# Tasks
watch = ()->

  gutil.log gutil.colors.bgBlue(" Watching file changes... ")

  chokidar = require("chokidar")

  watcher = chokidar.watch "./src/", {
    usePolling    : false
    useFsEvents   : true
    ignoreInitial : true
    ignored       : /([\/\\]\.)|src.(assets|test|vender)/
  }

  changeHandler = ( path )->
    if verbose then console.log "[Change]", path

    fileTaskDistribute( path )
    null

  watcher.on "add",    changeHandler
  watcher.on "change", changeHandler
  null

compile = ()->

  # gutil.log gutil.colors.bgBlue(" Compiling coffeescript... ")

  # # Walk through src instead of just using gulp.src, becuase gulp.src
  # # will just open all the files.
  # walker = walk.sync "./src", ( path, stat )->
  #   # Ignore vender/test/ui
  #   if path.match(compileIgnorePath)
  #     return

  #   # Only compile coffee.
  #   if endsWith path, ".coffee"
  #     fileTaskDistribute( path )
  #   null

  # walker.on "end", ()-> console.log "Walk Ends."
  null

module.exports =
  watch   : watch
  compile : compile
