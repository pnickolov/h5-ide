var Q, browser, coffee, compile, es, gulp, gutil, mocha, run, server, should;

Q = require("q");

gulp = require("gulp");

gutil = require("gulp-util");

mocha = require("gulp-mocha");

coffee = require("gulp-coffee");

should = require("should");

es = require("event-stream");

server = require("./server");

browser = require("../test/env/Browser.js");

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
  var e, testserver, zombie;
  try {
    zombie = require("zombie");
  } catch (_error) {
    e = _error;
    console.log(gutil.colors.bgYellow.black("  Cannot find zombie. Automated test is disabled.  "));
    return false;
  }
  testserver = server("./src", 3010, false, false);
  return browser.resources.post('http://api.xxx.io/session/', {
    body: '{"jsonrpc":"2.0","id":"1","method":"login","params":["test","aaa123aa",{"timezone":8}]}'
  }, function(error, response) {
    var res;
    res = JSON.parse(response.body.toString()).result[1];
    browser.setCookie({
      name: "session_id",
      value: res.session_id,
      maxAge: 3600 * 24 * 30,
      domain: "ide.xxx.io"
    });
    browser.setCookie({
      name: "usercode",
      value: res.username,
      maxAge: 3600 * 24 * 30,
      domain: "ide.xxx.io"
    });
    return browser.visit("/").then(function() {});
  });
};

module.exports = {
  compile: compile,
  run: run
};
