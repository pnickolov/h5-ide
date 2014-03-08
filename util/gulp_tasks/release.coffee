
gulp  = require("gulp")
gutil = require("gulp-util")
es    = require("event-stream")

coffee      = require("gulp-coffee")
include     = require("./plugins/include")
langsrc     = require("./plugins/langsrc")
confCompile = require("./plugins/conditional")
handlebars  = require("./plugins/handlebars")

util = require("./plugins/util")

logTask = ( msg )->
  console.log "[", gutil.colors.bgBlue.white(msg), "]"
  null

logCoffee = ()->
  es.through ( f )->
    if GLOBAL.gulpConfig.verbose
      console.log util.compileTitle( f.extra ), "#{f.relative}"
    @emit "data", f
    null

# A task to build IDE
build = ( debugMode ) ->

  #*** Copy assets file to `build` folder
  logTask "Copying Assets"
  gulp.src(["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"])
    .pipe( gulp.dest "./build/assets/" )


  #*** Copy js file to `build` folder
  logTask "Copying Js Files"
  gulp.src(["./src/js/*.js"]).pipe( gulp.dest "./build/js" )
  gulp.src(["./src/ui/*.js"]).pipe( gulp.dest "./build/ui" )
  gulp.src(["./src/vender/**/*"]).pipe( gulp.dest "./build/vender" )


  #*** Process `lang-source.coffee` and copy to `build` folder
  logTask "Compiling lang-source"
  gulp.src(["./src/nls/lang-source.coffee"]).pipe(langsrc("./build",false,GLOBAL.gulpConfig.verbose))


  #*** Process `*.coffee` and copy to `build` folder
  logTask "Compiling coffees"
  gulp.src(["./src/**/*.coffee", "!src/test/**/*"])
    .pipe( confCompile( true ) ) # Remove ### env:dev ###
    .pipe( coffee() ) # Compile coffee
    .pipe( logCoffee() )
    .pipe( gulp.dest "./build" )


  #*** Process all other `templates` and copy to `build` folder
  logTask "Compiling templates"
  gulp.src( ["./src/**/*.partials", "./src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html" ] )
    .pipe( confCompile(true) )
    .pipe( handlebars( GLOBAL.gulpConfig.verbose ) )
    .pipe( gulp.dest "./build" )


  #*** Process `./src/*.html` and copy to `build` folder
  logTask "Copying ./src/*.html"
  gulp.src(["./src/*.html"])
    .pipe( confCompile( true ) )
    .pipe( include() ) # Include other templates to the html
    .pipe( gulp.dest "./build" )


  #*** Use `r.js` to optimize the whole `build` folder

  #*** Git commit

  #*** Fetach all file version

  #*** Insert css version to html

  #*** Generate version for JS files

  #*** Final Git commit

  #*** Push to remote


  # gulp.src("./test/*")
  #   .pipe(handlebars())
  #   .pipe(gulp.dest("./build/"))
  # null

  # gulp.src("./src/500.html")
  #   .pipe(html())
  #   .pipe(gulp.dest("./build/"))
  null


module.exports = { build : build }
