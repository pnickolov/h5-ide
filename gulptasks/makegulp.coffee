
coffee = require("gulp-coffee");
gulp   = require("gulp");
Q      = require("q");

module.exports = ()->
  d = Q.defer()
  gulp.src( ["./gulptasks/*.coffee", "./gulptasks/plugins/*.coffee"], {"base":"./gulptasks"} )
      .pipe( coffee() )
      .pipe( gulp.dest("./gulptasks") )
      .on( "end", (()-> console.log("Gulp make successfully."); d.resolve()) )
  d.promise
