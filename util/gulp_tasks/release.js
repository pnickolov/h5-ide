(function() {
  var Q, SrcOption, Tasks, coffee, confCompile, dest, end, es, fileLogger, gulp, gutil, handlebars, ideversion, include, langsrc, logTask, requirejs, rjsconfig, util, variable;

  gulp = require("gulp");

  gutil = require("gulp-util");

  es = require("event-stream");

  Q = require("q");

  requirejs = require("requirejs");

  coffee = require("gulp-coffee");

  include = require("./plugins/include");

  langsrc = require("./plugins/langsrc");

  confCompile = require("./plugins/conditional");

  handlebars = require("./plugins/handlebars");

  ideversion = require("./plugins/ideversion");

  variable = require("./plugins/variable");

  rjsconfig = require("./plugins/rjsconfig");

  util = require("./plugins/util");

  SrcOption = {
    "base": "./src"
  };

  logTask = function(msg, noNewlineWhenNotVerbose) {
    msg = "[ " + (gutil.colors.bgBlue.white(msg)) + " ] ";
    if (noNewlineWhenNotVerbose && !GLOBAL.gulpConfig.verbose) {
      process.stdout.write(msg);
    } else {
      console.log(msg);
    }
    return null;
  };

  fileLogger = function() {
    return es.through(function(f) {
      if (GLOBAL.gulpConfig.verbose) {
        console.log(util.compileTitle(f.extra, false), "" + f.relative);
      } else {
        process.stdout.write(".");
      }
      this.emit("data", f);
      return null;
    });
  };

  dest = function() {
    return gulp.dest("./build");
  };

  end = function(d, printNewlineWhenNotVerbose) {
    if (printNewlineWhenNotVerbose && !GLOBAL.gulpConfig.verbose) {
      return function() {
        process.stdout.write("\n");
        return d.resolve();
      };
    } else {
      return function() {
        return d.resolve();
      };
    }
  };

  Tasks = {
    copyAssets: function() {
      var d, path;
      logTask("Copying Assets");
      path = ["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"];
      d = Q.defer();
      gulp.src(path, SrcOption).pipe(dest()).on("end", end(d));
      return d.promise;
    },
    copyJs: function() {
      var d, path;
      logTask("Copying Js Templates");
      path = ["./src/js/*.js", "./src/ui/*.js", "./src/vender/**/*", "./src/nls/**/*.js", "./src/component/stateeditor/lib/**/*.js", "./src/component/exporter/*.js", "./src/**/*.html"];
      d = Q.defer();
      gulp.src(path, SrcOption).pipe(dest()).on("end", end(d));
      return d.promise;
    },
    compileLangSrc: function() {
      var d;
      logTask("Compiling lang-source");
      d = Q.defer();
      gulp.src(["./src/nls/lang-source.coffee"]).pipe(langsrc("./build", false, GLOBAL.gulpConfig.verbose)).on("end", end(d));
      return d.promise;
    },
    compileCoffee: function() {
      var d, path;
      logTask("Compiling coffees", true);
      path = ["./src/**/*.coffee", "!src/test/**/*", "!lang-source.coffee"];
      d = Q.defer();
      gulp.src(path, SrcOption).pipe(confCompile(true)).pipe(coffee()).pipe(fileLogger()).pipe(dest()).on("end", end(d, true));
      return d.promise;
    },
    compileTemplate: function() {
      var d, path;
      logTask("Compiling templates", true);
      path = ["./src/**/*.partials", "./src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html"];
      d = Q.defer();
      gulp.src(path, SrcOption).pipe(confCompile(true)).pipe(handlebars(false)).pipe(fileLogger()).pipe(dest()).on("end", end(d, true));
      return d.promise;
    },
    processHtml: function() {
      var d, path;
      logTask("Processing ./src/*.html");
      path = ["./src/*.html"];
      d = Q.defer();
      gulp.src(path).pipe(confCompile(true)).pipe(include()).pipe(variable()).pipe(dest()).on("end", end(d));
      return d.promise;
    },
    concatJS: function() {
      logTask("Concating JS");
      requirejs.optimize(rjsconfig, function(buildres) {
        return null;
      }, function(err) {
        return console.log(err);
      });
      return true;
    }
  };

  module.exports = {
    build: function(debugMode) {
      ideversion.save();
      return [Tasks.copyAssets, Tasks.copyJs, Tasks.compileLangSrc, Tasks.compileCoffee, Tasks.compileTemplate, Tasks.processHtml].reduce(Q.when, Q());
    }
  };

}).call(this);
