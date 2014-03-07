
gulp = require("gulp")

#handlebars = require("./plugins/handlebars")
#html = require("./plugins/html")

build = ( debugMode ) ->
  # A task to build IDE

  # gulp.src("./test/*")
  #   .pipe(handlebars())
  #   .pipe(gulp.dest("./build/"))
  # null

  # gulp.src("./src/500.html")
  #   .pipe(html())
  #   .pipe(gulp.dest("./build/"))


module.exports = { build : build }
