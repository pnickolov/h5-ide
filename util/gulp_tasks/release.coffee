
gulp = require("gulp")

#handlebars = require("./plugins/handlebars")

include = require("./plugins/include")

# A task to build IDE
build = ( debugMode ) ->

  # 1. Copy JS/assets file to `build` folder

  # 2. Process `./src/*.html` and copy to `build` folder

  # 3. Process `*.coffee` and copy to `build` folder

  # 4. Process all other `templates` and copy to `build` folder

  # 5. Use `r.js` to optimize the whole `build` folder

  # 6. Git commit

  # 7. Fetach all file version

  # 8. Insert css version to html

  # 9. Generate version for JS files

  # 10. Final Git commit

  # 11. Push to remote


  # gulp.src("./test/*")
  #   .pipe(handlebars())
  #   .pipe(gulp.dest("./build/"))
  # null

  # gulp.src("./src/500.html")
  #   .pipe(html())
  #   .pipe(gulp.dest("./build/"))
  null


module.exports = { build : build }
