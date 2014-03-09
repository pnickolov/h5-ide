
gulp      = require("gulp")
gutil     = require("gulp-util")
es        = require("event-stream")
Q         = require("q")
requirejs = require("requirejs")

coffee      = require("gulp-coffee")
include     = require("./plugins/include")
langsrc     = require("./plugins/langsrc")
confCompile = require("./plugins/conditional")
handlebars  = require("./plugins/handlebars")
ideversion  = require("./plugins/ideversion")
variable    = require("./plugins/variable")
rjsconfig   = require("./plugins/rjsconfig")

util = require("./plugins/util")

SrcOption = {"base":"./src"}

logTask = ( msg, noNewlineWhenNotVerbose )->
  msg = "[ #{gutil.colors.bgBlue.white(msg)} ] "

  if noNewlineWhenNotVerbose and not GLOBAL.gulpConfig.verbose
    process.stdout.write msg
  else
    console.log msg
  null

fileLogger = ()->
  es.through ( f )->
    if GLOBAL.gulpConfig.verbose
      console.log util.compileTitle( f.extra, false ), "#{f.relative}"
    else
      process.stdout.write "."

    @emit "data", f
    null

dest = ()-> gulp.dest "./build"
end  = ( d, printNewlineWhenNotVerbose )->
  if printNewlineWhenNotVerbose and not GLOBAL.gulpConfig.verbose
    ()->
      process.stdout.write "\n"
      d.resolve()
  else
    ()-> d.resolve()

Tasks =
  copyAssets : ()->
    logTask "Copying Assets"

    path = ["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"]

    d = Q.defer()
    gulp.src( path, SrcOption ).pipe( dest() ).on( "end", end(d) )
    d.promise

  copyJs : ()->
    logTask "Copying Js Files"

    path = ["./src/js/*.js", "./src/ui/*.js", "./src/vender/**/*"]

    d = Q.defer()
    gulp.src( path, SrcOption ).pipe( dest() ).on( "end", end(d) )
    d.promise

  compileLangSrc : ()->
    logTask "Compiling lang-source"

    d = Q.defer()
    gulp.src(["./src/nls/lang-source.coffee"])
        .pipe(langsrc("./build",false,GLOBAL.gulpConfig.verbose))
        .on( "end", end(d) )
    d.promise

  compileCoffee : ()->
    logTask "Compiling coffees", true

    path = ["./src/**/*.coffee", "!src/test/**/*", "!lang-source.coffee"]

    d = Q.defer()
    gulp.src( path, SrcOption )
      .pipe( confCompile( true ) ) # Remove ### env:dev ###
      .pipe( coffee() ) # Compile coffee
      .pipe( fileLogger() )
      .pipe( dest() )
      .on( "end", end(d, true) )
    d.promise

  compileTemplate : ()->
    logTask "Compiling templates", true

    path = ["./src/**/*.partials", "./src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html" ]

    d = Q.defer()
    gulp.src( path, SrcOption )
      .pipe( confCompile(true) )
      .pipe( handlebars( false ) )
      .pipe( fileLogger() )
      .pipe( dest() )
      .on( "end", end(d, true) )
    d.promise

  processHtml : ()->
    logTask "Processing ./src/*.html"

    path = ["./src/*.html"]

    d = Q.defer()
    gulp.src( path )
      .pipe( confCompile( true ) )
      .pipe( include() ) # Include other templates or variables to the html
      .pipe( variable() )
      .pipe( dest() )
      .on( "end", end(d) )
    d.promise

  concatJS : ()->
    logTask "Concating JS"

    requirejs.optimize( rjsconfig

    , (buildres)->
      null
    , (err)->
      console.log err
    )

    true




# A task to build IDE
  #*** Copy assets file to `build` folder
  #*** Copy js file to `build` folder
  #*** Process `lang-source.coffee` and copy to `build` folder
  #*** Process `*.coffee` and copy to `build` folder
  #*** Process all other `templates` and copy to `build` folder
  #*** Process `./src/*.html` and copy to `build` folder
  #*** Use `r.js` to optimize the whole `build` folder
  #*** Git commit
  #*** Fetach all file version
  #*** Insert css version to html
  #*** Generate version for JS files
  #*** Final Git commit
  #*** Push to remote
module.exports =
  build : ( debugMode )->
    ideversion.save()

    [
      Tasks.copyAssets
      Tasks.copyJs
      Tasks.compileLangSrc
      Tasks.compileCoffee
      Tasks.compileTemplate
      Tasks.processHtml
      Tasks.concatJS
    ].reduce( Q.when, Q() )
