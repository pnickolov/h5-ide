
gulp = require("gulp")

#handlebars = require("./plugins/handlebars")
#include = require("./plugins/include")

build = ( debugMode ) ->
  # A task to build IDE

  # gulp.src("./test/*")
  #   .pipe(handlebars())
  #   .pipe(gulp.dest("./build/"))
  # null

  # gulp.src("./src/500.html")
  #   .pipe(include())
  #   .pipe(gulp.dest("./src/500-o.html"))


module.exports = { build : build }
