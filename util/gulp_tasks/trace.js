(function() {
  var Q, copyJs, gulp, requirejs, rjsconfig, util;

  Q = require("q");

  gulp = require("gulp");

  rjsconfig = require("./plugins/rjsconfig");

  requirejs = require("./plugins/r");

  util = require("./plugins/util");

  copyJs = function() {
    var d, p;
    p = ["./src/**/*.js", "!./src/test/**/*"];
    d = Q.defer();
    gulp.src(p).pipe(gulp.dest("./build")).on("end", function() {
      return d.resolve();
    });
    return d.promise;
  };

  module.exports = function() {
    console.log("Tracing dependency of each module.");
    console.log("Don't forget to run `gulp dev_all` before tracing.");
    return copyJs().then(function() {
      var d;
      d = Q.defer();
      requirejs.optimize(rjsconfig(true, "./trace", true), function(buildres) {
        console.log("Module Dependencies:");
        console.log(buildres);
        util.deleteFolderRecursive(process.cwd() + "/trace");
        util.deleteFolderRecursive(process.cwd() + "/build");
        return d.resolve();
      }, function(err) {
        console.log(err);
        return d.reject();
      });
      return d.promise;
    });
  };

}).call(this);
