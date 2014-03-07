
#handlebars = require("./handlebars")
#gulp = require("gulp")

build = ( debugMode ) ->
  # A task to build IDE

  # gulp.src("./test/*")
  #   .pipe(handlebars())
  #   .pipe(gulp.dest("./build/"))
  # null


module.exports = { build : build }
