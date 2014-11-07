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

    /*
    console.log "Loading IDE in Zombie."
    
     * Create a zombie browser
    Browser = require("../../../test/env/Browser")
    Browser.globalBrowser.visit("http://127.0.0.1:3010").then ()->
    
      gulp.src(p)
        .pipe mocha({reporter: GLOBAL.gulpConfig.testReporter})
        .pipe es.through ()->
           * Don't know why, but we need a pipe here,
           * so that the `end` event will be delivered.
          true
        .on "end", ()-> d.resolve()
        .on "error", ()->
          console.log gutil.colors.bgRed.black "  Deploy aborted, due to test failure.  "
          d.reject()
      null
    .fail (error)->
      console.log gutil.colors.bgRed.black "  Deploy aborted, due to zombie fails to run.  "
      d.reject()
     */
    gulp.src(p).pipe(mocha({
      reporter: GLOBAL.gulpConfig.testReporter
    })).pipe(es.through(function() {
      return true;
    })).on("end", function() {
      return d.resolve();
    }).on("error", function() {
      console.log(gutil.colors.bgRed.black("  Deploy aborted, due to test failure.  "));
      return d.reject();
    });
    return d.promise;
  };

  module.exports = function(url) {
    var e, zombie;
    try {
      zombie = require("zombie");
    } catch (_error) {
      e = _error;
      console.log(gutil.colors.bgYellow.black("  Cannot find zombie. Automated test is disabled.  "));
      return false;
    }
    return compileTestCoffee().then(runTest);
  };

}).call(this);
