(function() {
  var Q, coffee, compileTestCoffee, confCompile, es, gulp, gutil, mocha, runTest, should;

  Q = require("q");

  gulp = require("gulp");

  gutil = require("gulp-util");

  mocha = require("gulp-mocha");

  coffee = require("gulp-coffee");

  should = require("should");

  es = require("event-stream");

  confCompile = require("./conditional");

  compileTestCoffee = function(debugMode) {
    var d, pipe;
    if (GLOBAL.gulpConfig.verbose) {
      console.log("Compiling Testcase");
    }
    d = Q.defer();
    pipe = gulp.src(["./test/**/*.coffee"]).pipe(confCompile(true)).pipe(coffee()).pipe(gulp.dest("./test")).on("end", function() {
      return d.resolve();
    });
    return d.promise;
  };

  runTest = function() {
    var d, p;
    d = Q.defer();
    p = ["./test/**/*.js", "!./test/Browser.js"];
    gulp.src(p).pipe(mocha({
      reporter: GLOBAL.gulpConfig.testReporter
    })).pipe(es.through(function() {

      /*
        Don't know why, but we need a pipe here, so that the `end` event
        will be delivered.
       */
      return true;
    })).on("end", function() {
      return d.resolve();
    }).on("error", function() {
      return d.reject();
    });
    null;
    return d.promise;
  };

  module.exports = function(url) {
    var e, zombie;
    try {
      zombie = require("zombie");
    } catch (_error) {
      e = _error;
      console.log(gutil.colors.bgYellow.black("  Cannot find zombie. Automated test is not disabled.  "));
      return false;
    }
    return compileTestCoffee().then(runTest);
  };

}).call(this);
