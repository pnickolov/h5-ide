(function() {
  var EventEmitter, Helper, Q, StreamFuncs, cached, changeHandler, checkWatchHealthy, chokidar, coffee, coffeelint, coffeelintOptions, compileCoffeeOnlyRegex, compileDev, compileIgnorePath, confCompile, es, fs, globwatcher, gulp, gulpif, gutil, handlebars, jshint, langsrc, lintReporter, path, tinylr, util, watch;

  gulp = require("gulp");

  gutil = require("gulp-util");

  path = require("path");

  es = require("event-stream");

  Q = require("q");

  fs = require("fs");

  EventEmitter = require("events").EventEmitter;

  tinylr = require("tiny-lr");

  chokidar = require("chokidar");

  coffee = require("gulp-coffee");

  coffeelint = require("gulp-coffeelint");

  gulpif = require("gulp-if");

  confCompile = require("./plugins/conditional");

  cached = require("./plugins/cached");

  jshint = require("./plugins/jshint");

  lintReporter = require('./plugins/reporter');

  langsrc = require("./plugins/langsrc");

  handlebars = require("./plugins/handlebars");

  globwatcher = require("./plugins/globwatcher");

  util = require("./plugins/util");

  coffeelintOptions = {
    indentation: {
      level: "ignore"
    },
    no_tabs: {
      level: "ignore"
    },
    max_line_length: {
      level: "ignore"
    },
    no_debugger: {
      level: "ignore"
    }
  };

  compileIgnorePath = /.src.(test|vender|ui)/;

  compileCoffeeOnlyRegex = /.src.(service|model)/;

  Helper = {
    shouldLintCoffee: function(f) {
      return !f.path.match(compileCoffeeOnlyRegex);
    },
    compileCompass: function() {
      var compassSuccess;
      compassSuccess = true;
      gutil.log(gutil.colors.bgBlue.white(" Compiling scss... "));
      return util.runCommand("compass", ["compile"], {
        cwd: process.cwd() + "/src/assets"
      }, {
        onError: function(e) {
          if (e.code === "ENOENT" && e.errno === "ENOENT" && e.syscall === "spawn") {
            compassSuccess = false;
            console.log("[" + gutil.colors.yellow("Compass Missing") + "] Scss files are not re-compiled.");
          }
          return null;
        },
        onData: function(d) {
          if (compassSuccess) {
            return process.stdout.write(d);
          }
        }
      });
    },
    runCompass: function() {
      var compassSuccess;
      compassSuccess = false;
      gutil.log(gutil.colors.bgBlue.white(" Watching scss... "));
      return util.runCommand("compass", ["watch"], {
        cwd: process.cwd() + "/src/assets"
      }, {
        onError: function(e) {
          if (e.code === "ENOENT" && e.errno === "ENOENT" && e.syscall === "spawn") {
            console.log("[" + gutil.colors.yellow("Compass Missing") + "] Cannot find compass, don't manually edit compressed css.");
          }
          return null;
        },
        onData: function(d) {
          if (d.indexOf("Compass is polling") > -1) {
            compassSuccess = true;
            return;
          }
          if (!compassSuccess) {
            return;
          }
          process.stdout.write(d);
          return null;
        }
      });
    },
    lrServer: void 0,
    createLrServer: function() {
      if (Helper.lrServer !== void 0) {
        return;
      }
      gutil.log(gutil.colors.bgBlue.white(" Starting livereload server... "));
      Helper.lrServer = tinylr();
      Helper.lrServer.server.removeAllListeners('error');
      Helper.lrServer.server.on("error", function(e) {
        if (e.code !== "EADDRINUSE") {
          return;
        }
        console.error('[LR Error] Cannot start livereload server. You already have a server listening on %s', Helper.lrServer.port);
        Helper.lrServer = null;
        return null;
      });
      Helper.lrServer.listen(GLOBAL.gulpConfig.livereloadServerPort, function(err) {
        if (err) {
          gutil.log("[LR Error]", "Cannot start livereload server");
          Helper.lrServer = null;
        }
        return null;
      });
      return null;
    },
    watchRetry: 0,
    watchIsWorking: false,
    createWatcher: function() {
      var compileAfterGitAction, gitDebounceTimer, gulpWatch, watcher;
      if (GLOBAL.gulpConfig.pollingWatch) {
        gutil.log(gutil.colors.bgBlue.white(" Watching file changes... ") + " [Polling]");
        watcher = new EventEmitter();
        gulp.watch(["./src/**/*.coffee", "./src/**/*.html", "./src/**/*.partials", "./util/gulp_tasks/**/*.coffee", "./src/assets/**/*", "!src/include/*.html"], function(event) {
          var type;
          if (event.type === "added") {
            type = "add";
          } else if (event.type === "changed") {
            type = "change";
          } else {
            return;
          }
          watcher.emit(type, event.path);
          return null;
        });
      } else {
        gutil.log(gutil.colors.bgBlue.white(" Watching file changes... ") + " [Native FSevent, vim might not trigger changes]");
        watcher = chokidar.watch(["./src", "./util/gulp_tasks"], {
          usePolling: false,
          useFsEvents: true,
          ignoreInitial: true,
          ignored: /([\/\\]\.)|src.(test|vender)/
        });
        gitDebounceTimer = null;
        compileAfterGitAction = function() {
          console.log("[" + gutil.colors.green("Git Action Detected @" + ((new Date()).toLocaleTimeString())) + "] Ready to re-compile the whole project");
          gitDebounceTimer = null;
          return compileDev();
        };
        gulpWatch = globwatcher(["./.git/index"], function(event) {
          if (gitDebounceTimer === null) {
            gitDebounceTimer = setTimeout(compileAfterGitAction, GLOBAL.gulpConfig.gitPollingDebounce || 1000);
          }
          return null;
        });
        gulpWatch.on("error", function(error) {
          return console.log("[Gulp Watch Git Error]", error);
        });
      }
      return watcher;
    }
  };

  StreamFuncs = {
    coffeeErrorPrinter: function(error) {
      console.log(gutil.colors.red.bold("\n[CoffeeError]"), error.message.replace(util.cwd, "."));
      util.notify("Error occur when compiling " + error.message.replace(util.cwd, ".").split(":")[0]);
      return null;
    },
    throughLiveReload: function() {
      return es.through(function(file) {
        if (util.endsWith(file.path, ".scss")) {
          return;
        }
        if (Helper.lrServer) {
          Helper.lrServer.changed({
            body: {
              files: [file.path]
            }
          });
        }
        return null;
      });
    },
    throughCoffee: function() {
      var coffeeBranch, coffeeCompile, conditonalLint, pipeline;
      conditonalLint = gulpif(Helper.shouldLintCoffee, coffeelint(void 0, coffeelintOptions));
      coffeeBranch = cached(conditonalLint);
      coffeeCompile = conditonalLint.pipe(confCompile(false)).pipe(coffee({
        sourceMap: GLOBAL.gulpConfig.coffeeSourceMap
      }));
      pipeline = coffeeCompile.pipe(es.through(function(f) {
        console.log(util.compileTitle(f.extra), "" + f.relative);
        return this.emit("data", f);
      })).pipe(es.through(function(f) {
        if (f.path.match(/src.lib.handlebarhelpers.js/)) {
          handlebars.reloadConfig();
        }
        return this.emit("data", f);
      })).pipe(gulpif(Helper.shouldLintCoffee, jshint())).pipe(gulpif(Helper.shouldLintCoffee, lintReporter())).pipe(gulp.dest("."));
      if (GLOBAL.gulpConfig.reloadJsHtml) {
        pipeline.pipe(StreamFuncs.throughLiveReload());
      }
      coffeeCompile.removeAllListeners("error");
      coffeeCompile.on("error", StreamFuncs.coffeeErrorPrinter);
      return coffeeBranch;
    },
    throughHandlebars: function() {
      var pipeline;
      pipeline = handlebars();
      pipeline.pipe(gulp.dest("."));
      return cached(pipeline);
    },
    workStream: null,
    workEndStream: null,
    createStreamObject: function() {
      if (StreamFuncs.workStream) {
        return;
      }
      StreamFuncs.workStream = es.through();
      StreamFuncs.workEndStream = StreamFuncs.setupCompileStream(StreamFuncs.workStream);
      return null;
    },
    setupCompileStream: function(stream) {
      var assetBranch, coffeeBranch, coffeeBranchRegex, langSrcBranch, langeSrcBranchRegex, liveReloadBranchRegex, templateBranch, templateBranchRegex;
      assetBranch = StreamFuncs.throughLiveReload();
      langSrcBranch = langsrc.langCache();
      coffeeBranch = StreamFuncs.throughCoffee();
      templateBranch = StreamFuncs.throughHandlebars();
      langeSrcBranchRegex = /lang-source\/.*\.coffee/;
      coffeeBranchRegex = /\.coffee$/;
      templateBranchRegex = /(\.partials)|(\.html)$/;
      if (GLOBAL.gulpConfig.reloadJsHtml) {
        liveReloadBranchRegex = /(src.assets)|(\.js$)/;
      } else {
        liveReloadBranchRegex = /src.assets/;
      }
      return stream.pipe(gulpif(langeSrcBranchRegex, langSrcBranch, true)).pipe(gulpif(templateBranchRegex, templateBranch, true)).pipe(gulpif(coffeeBranchRegex, coffeeBranch, true)).pipe(gulpif(liveReloadBranchRegex, assetBranch, true));
    }
  };

  changeHandler = function(path) {
    var stats;
    Helper.watchIsWorking = true;
    if (!fs.existsSync(path)) {
      return;
    }
    stats = fs.statSync(path);
    if (stats.isDirectory()) {
      return;
    }
    if (GLOBAL.gulpConfig.verbose) {
      console.log("[Change]", path);
    }
    if (path.match(/src.assets/)) {
      StreamFuncs.workStream.emit("data", {
        path: path
      });
    } else if (path.match(/src.[^\/]+\.html/)) {
      return;
    } else {
      fs.readFile(path, function(err, data) {
        if (!data) {
          return;
        }
        StreamFuncs.workStream.emit("data", new gutil.File({
          cwd: util.cwd,
          base: util.cwd,
          path: path,
          contents: data
        }));
        return null;
      });
    }
    return null;
  };

  checkWatchHealthy = function(watcher) {
    if (GLOBAL.gulpConfig.pollingWatch) {
      return;
    }
    fs.writeFileSync("./src/robots.txt", fs.readFileSync("./src/robots.txt"));
    return setTimeout(function() {
      if (!Helper.watchIsWorking) {
        console.log("[Info]", "Watch is not working. Will retry in 2 seconds.");
        util.notify("Watch is not working. Will retry in 2 seconds.");
        watcher.removeAllListeners();
        return setTimeout((function() {
          return watch();
        }), 2000);
      }
    }, 500);
  };

  watch = function() {
    var watcher;
    ++Helper.watchRetry;
    if (Helper.watchRetry > 3) {
      console.log(gutil.colors.red.bold("[Fatal]", "Watch is still not working. Please manually retry."));
      util.notify("Watch is still not working. Please manually retry.");
      return;
    }
    Helper.createLrServer();
    Helper.runCompass();
    StreamFuncs.createStreamObject();
    watcher = Helper.createWatcher();
    watcher.on("add", changeHandler);
    watcher.on("change", changeHandler);
    watcher.on("error", function(e) {
      return console.log("[error]", e);
    });
    checkWatchHealthy(watcher);
    return null;
  };

  compileDev = function() {
    var compileStream, deferred, p;
    p = ["src/**/*.coffee", "src/**/*.partials", "src/**/*.html", "!src/*.html", "!src/include/*.html", "!src/test/**/*"];
    deferred = Q.defer();
    StreamFuncs.createStreamObject();
    compileStream = gulp.src(p, {
      cwdbase: true
    }).pipe(es.through(function(f) {
      StreamFuncs.workStream.emit("data", f);
      return null;
    }));
    compileStream.once("end", function() {
      langsrc.langWrite();
      return Helper.compileCompass().then(function(value) {
        return deferred.resolve();
      });
    });
    return deferred.promise;
  };

  module.exports = {
    watch: watch,
    compileDev: compileDev
  };

}).call(this);
