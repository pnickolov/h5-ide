var Q, coffee, compile, es, gulp, gutil, mocha, run;

Q = require("q");

gulp = require("gulp");

gutil = require("gulp-util");

mocha = require("gulp-mocha");

coffee = require("gulp-coffee");

es = require("event-stream");

compile = function() {
  var d;
  d = Q.defer();
  gulp.src(["./test/**/*.coffee"]).pipe(coffee({
    bare: true
  })).pipe(gulp.dest("./test")).on("end", (function() {
    console.log("Compile test successfully.");
    return d.resolve();
  }));
  return d.promise;
};

run = function() {
  var browser, d, e, noop, server, testserver, zombie;
  server = require("./server");
  browser = require("../test/env/Browser.js");
  try {
    zombie = require("zombie");
  } catch (_error) {
    e = _error;
    console.log(gutil.colors.bgYellow.black("  Cannot find zombie. Automated test is disabled.  "));
    return false;
  }
  testserver = server("./src", 3010, false, false);
  d = Q.defer();
  noop = function() {};
  browser.launchIDE().then(function(response) {
    var shutDown;
    console.log("\n\n\n[" + gutil.colors.green("Debug @" + ((new Date()).toLocaleTimeString())) + "] Starting tests.");
    browser.silent = true;
    shutDown = function() {
      browser.close();
      testserver.close();
      d.resolve();
      return process.exit();
    };
    return gulp.src(["./test/**/*.js", "!./test/env/Browser.js"]).pipe(mocha({
      reporter: GLOBAL.gulpConfig.testReporter,
      timeout: 20000
    })).on("error", function(e) {
      console.log(gutil.colors.bgRed.black(" Test failed. "));
      return this.emit("end");
    }).pipe(es.through(noop, shutDown));
  }, function(error) {
    return d.reject({
      error: error,
      msg: "Cannot login the server to test."
    });
  });
  return d.promise;
};

module.exports = {
  compile: compile,
  run: run
};
