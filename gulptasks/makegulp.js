var Q, coffee, gulp;

coffee = require("gulp-coffee");

gulp = require("gulp");

Q = require("q");

module.exports = function() {
  var d;
  d = Q.defer();
  gulp.src(["./gulptasks/*.coffee", "./gulptasks/plugins/*.coffee"], {
    "base": "./gulptasks"
  }).pipe(coffee({
    bare: true
  })).pipe(gulp.dest("./gulptasks")).on("end", (function() {
    console.log("Gulp make successfully.");
    return d.resolve();
  }));
  return d.promise;
};
