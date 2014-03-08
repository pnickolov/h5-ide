
gulp = require("gulp")
es   = require("event-stream")

#handlebars = require("./plugins/handlebars")

include     = require("./plugins/include")
langsrc     = require("./plugins/langsrc")
coffee      = require("gulp-coffee")
confCompile = require("./plugins/conditional")
handlebars  = require("./plugins/handlebars")

# A task to build IDE
build = ( debugMode ) ->

  #*** Copy assets file to `build` folder
  gulp.src(["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"])
    .pipe( gulp.dest "./build/assets/" )


  #*** Copy js file to `build` folder
  gulp.src(["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"])
    .pipe( gulp.dest "./build/assets/" )


  #*** Process `lang-source.coffee` and copy to `build` folder
  gulp.src(["./src/nls/lang-source.coffee"]).pipe(langsrc("./build",false))


  #*** Process `*.coffee` and copy to `build` folder
  gulp.src(["./src/**/*.coffee"])
    .pipe( confCompile( true ) ) # Remove ### env:dev ###
    .pipe( coffee() ) # Compile coffee
    .pipe( gulp.dest "./build" )


  #*** Process all other `templates` and copy to `build` folder
  gulp.src( ["./src/**/*.partials", "./src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html" ] )
    .pipe( confCompile(true) )
    .pipe( handlebars() )
    .pipe( gulp.dest "./build" )


  #*** Process `./src/*.html` and copy to `build` folder
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
