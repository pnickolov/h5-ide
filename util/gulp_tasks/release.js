(function() {
  var Q, SrcOption, Tasks, coffee, confCompile, dest, end, es, fileLogger, gulp, gutil, handlebars, ideversion, include, langsrc, logTask, requirejs, rjsconfig, stripdDebug, util, variable;

  gulp = require("gulp");

  gutil = require("gulp-util");

  es = require("event-stream");

  Q = require("q");

  coffee = require("gulp-coffee");

  include = require("./plugins/include");

  langsrc = require("./plugins/langsrc");

  confCompile = require("./plugins/conditional");

  handlebars = require("./plugins/handlebars");

  ideversion = require("./plugins/ideversion");

  variable = require("./plugins/variable");

  rjsconfig = require("./plugins/rjsconfig");

  requirejs = require("./plugins/r");

  stripdDebug = require("gulp-strip-debug");

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
    cleanRepo: function() {
      logTask("Removing ignored files in src (git clean -Xf)");
      return util.runCommand("git", ["clean", "-Xf"], {
        cwd: process.cwd() + "/src"
      }, function(data) {
        console.log(data);
        return null;
      });
    },
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
      logTask("Copying Js & Templates");
      path = ["./src/**/*.js", "./src/**/*.html", "!./src/test/**/*"];
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
    compileCoffee: function(debugMode) {
      return function() {
        var d, path, pipe;
        logTask("Compiling coffees", true);
        path = ["./src/**/*.coffee", "!src/test/**/*", "!./src/nls/lang-source.coffee"];
        d = Q.defer();
        pipe = gulp.src(path, SrcOption).pipe(confCompile(true)).pipe(coffee()).pipe(fileLogger());
        if (!debugMode) {
          pipe = pipe.pipe(stripdDebug());
        }
        pipe.pipe(dest()).on("end", end(d, true));
        return d.promise;
      };
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
    concatJS: function(debug, outputPath) {
      return function() {
        var d;
        logTask("Concating JS");
        d = Q.defer();
        requirejs.optimize(rjsconfig(debug, outputPath), function(buildres) {
          console.log("Concat result:");
          console.log(buildres);
          return d.resolve();
        }, function(err) {
          return console.log(err);
        });
        return d.promise;
      };
    },
    removeBuildFolder: function() {
      util.deleteFolderRecursive(process.cwd() + "/build");
      return true;
    }
  };

  module.exports = {
    build: function(mode) {
      var debugMode, deploy, outputPath;
      deploy = mode !== "qa";
      debugMode = mode === "qa" || mode === "debug";
      outputPath = mode === "qa" ? "./qa" : void 0;
      ideversion.read(deploy);
      return [Tasks.cleanRepo].reduce(Q.when, Q());
    }
  };

}).call(this);
