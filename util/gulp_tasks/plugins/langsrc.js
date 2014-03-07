(function() {
  var buildLangSrc, cached, coffee, compileTitle, es, gulp, gutil, log, noop, vm;

  cached = require("./cached");

  es = require("event-stream");

  vm = require("vm");

  gulp = require("gulp");

  gutil = require("gulp-util");

  coffee = require("gulp-coffee");

  buildLangSrc = require("../../../config/lang");

  compileTitle = function(extra) {
    var title;
    title = "[" + gutil.colors.green("Compile @" + ((new Date()).toLocaleTimeString())) + "]";
    if (extra) {
      title += " " + gutil.colors.inverse(extra);
    }
    return title;
  };

  log = function(e) {
    return console.log(e);
  };

  noop = function() {};

  module.exports = function(dest, useCache) {
    var gruntMock, pipeline, startPipeline;
    if (dest == null) {
      dest = ".";
    }
    if (useCache == null) {
      useCache = true;
    }
    if (useCache) {
      startPipeline = cached(coffee());
    } else {
      startPipeline = coffee();
    }
    pipeline = startPipeline.pipe(es.through(function(file) {
      var ctx;
      console.log(compileTitle(), "lang-souce.coffee");
      ctx = vm.createContext({
        module: {}
      });
      vm.runInContext(file.contents.toString("utf8"), ctx);
      buildLangSrc.run(gruntMock, noop, ctx.module.exports);
      return null;
    }));
    pipeline.pipe(gulp.dest(dest));
    gruntMock = {
      log: {
        error: log
      },
      file: {
        write: (function(_this) {
          return function(p1, p2) {
            var cwd;
            cwd = process.cwd();
            pipeline.emit("data", new gutil.File({
              cwd: cwd,
              base: cwd,
              path: p1,
              contents: new Buffer(p2)
            }));
            return null;
          };
        })(this)
      }
    };
    return startPipeline;
  };

}).call(this);
