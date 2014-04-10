(function() {
  var Q, SrcOption, Tasks, coffee, confCompile, dest, end, es, fileLogger, fs, gulp, gutil, handlebars, ideversion, include, langsrc, logTask, path, requirejs, rjsconfig, rjsreporter, server, stdRedirect, stripdDebug, unittest, util, variable;

  gulp = require("gulp");

  gutil = require("gulp-util");

  es = require("event-stream");

  fs = require("fs");

  Q = require("q");

  path = require("path");

  coffee = require("gulp-coffee");

  stripdDebug = require("gulp-strip-debug");

  include = require("./plugins/include");

  langsrc = require("./plugins/langsrc");

  confCompile = require("./plugins/conditional");

  handlebars = require("./plugins/handlebars");

  ideversion = require("./plugins/ideversion");

  variable = require("./plugins/variable");

  rjsconfig = require("./plugins/rjsconfig");

  requirejs = require("./plugins/r");

  rjsreporter = require("./plugins/rjsreporter");

  unittest = require("./plugins/test");

  util = require("./plugins/util");

  server = require("./server");

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

  stdRedirect = function(d) {
    process.stdout.write(d);
    return null;
  };

  Tasks = {
    removeRedirectForPublic: function() {
      var d, p, pipe;
      logTask("Stripping https redirect", true);
      p = ["./src/js/**/config.coffee"];
      d = Q.defer();
      pipe = gulp.src(p, SrcOption).pipe(es.through(function(f) {
        var newContent, stripHttpsRedirectRegex;
        stripHttpsRedirectRegex = /### AHACKFORRELEASINGPUBLICVERSION ###/g;
        newContent = f.contents.toString("utf8").replace(stripHttpsRedirectRegex, "###                                   ");
        f.contents = new Buffer(newContent);
        this.emit("data", f);
        return null;
      })).pipe(confCompile(true)).pipe(coffee()).pipe(fileLogger()).pipe(stripdDebug()).pipe(dest()).on("end", end(d, true));
      return d.promise;
    },
    cleanRepo: function() {
      logTask("Removing ignored files in src (git clean -Xf)");
      return util.runCommand("git", ["clean", "-Xdf"], {
        cwd: process.cwd() + "/src"
      }, stdRedirect);
    },
    checkGitVersion: function() {
      var d;
      logTask("Checking Git Version");
      d = Q.defer();
      util.runCommand("git", ["--version"], {}, function(version) {
        if (!version) {
          return;
        }
        version = version.split(" ") || [];
        version = parseFloat(version[2]);
        if (isNaN(version) || version < 1.9) {
          d.reject("Deployment need Git >=1.9");
        }
        return d.resolve(true);
      });
      return d.promise;
    },
    copyAssets: function() {
      var d, p;
      logTask("Copying Assets");
      p = ["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"];
      d = Q.defer();
      gulp.src(p, SrcOption).pipe(dest()).on("end", end(d));
      return d.promise;
    },
    copyJs: function() {
      var d, p;
      logTask("Copying Js & Templates");
      p = ["./src/**/*.js", "!./src/test/**/*"];
      d = Q.defer();
      gulp.src(p, SrcOption).pipe(confCompile(true)).pipe(dest()).on("end", end(d));
      return d.promise;
    },
    compileLangSrc: function() {
      var d;
      logTask("Compiling lang-source");
      d = Q.defer();
      gulp.src(["./src/nls/lang-source.coffee"], SrcOption).pipe(langsrc("./build", false, GLOBAL.gulpConfig.verbose, true)).on("end", end(d));
      return d.promise;
    },
    compileCoffee: function(debugMode) {
      return function() {
        var d, p, pipe;
        logTask("Compiling coffees", true);
        p = ["./src/**/*.coffee", "!src/test/**/*", "!./src/nls/lang-source.coffee"];
        d = Q.defer();
        pipe = gulp.src(p, SrcOption).pipe(confCompile(true)).pipe(coffee()).pipe(fileLogger());
        if (!debugMode) {
          pipe = pipe.pipe(stripdDebug());
        }
        pipe.pipe(dest()).on("end", end(d, true));
        return d.promise;
      };
    },
    compileTemplate: function() {
      var d, p;
      logTask("Compiling templates", true);
      p = ["./src/**/*.partials", "./src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html"];
      d = Q.defer();
      gulp.src(p, SrcOption).pipe(confCompile(true)).pipe(handlebars(false)).pipe(fileLogger()).pipe(dest()).on("end", end(d, true));
      return d.promise;
    },
    processHtml: function() {
      var d, p;
      logTask("Processing ./src/*.html");
      p = ["./src/*.html"];
      d = Q.defer();
      gulp.src(p).pipe(confCompile(true)).pipe(include()).pipe(variable()).pipe(dest()).on("end", end(d));
      return d.promise;
    },
    concatJS: function(debug, outputPath) {
      return function() {
        var d;
        logTask("Concating JS");
        d = Q.defer();
        requirejs.optimize(rjsconfig(debug, outputPath), function(buildres) {
          if (rjsreporter(buildres)) {
            return d.resolve();
          } else {
            console.log(gutil.colors.bgRed.white("Aborted due to concat error"));
            return d.reject();
          }
        }, function(err) {
          console.log(err);
          return d.reject();
        });
        return d.promise;
      };
    },
    removeBuildFolder: function() {
      util.deleteFolderRecursive(process.cwd() + "/build");
      return true;
    },
    fetchRepo: function(repoBranch) {
      return function() {
        var hadError, params, result;
        logTask("Checking out h5-ide-build");
        if (!util.deleteFolderRecursive(process.cwd() + "/h5-ide-build")) {
          throw new Error("Cannot delete ./h5-ide-build, please manually delete it then retry.");
        }
        params = ["clone", GLOBAL.gulpConfig.buildRepoUrl, "-v", "--progress", "--depth", "1", "-b", repoBranch];
        if (GLOBAL.gulpConfig.buildUsername) {
          params.push("-c");
          params.push("user.name=\"" + GLOBAL.gulpConfig.buildUsername + "\"");
        }
        if (GLOBAL.gulpConfig.buildEmail) {
          params.push("-c");
          params.push("user.email=\"" + GLOBAL.gulpConfig.buildEmail + "\"");
        }
        hadError = false;
        result = util.runCommand("git", params, {}, function(d, type) {
          if (d.indexOf("fatal") !== -1) {
            console.log(d);
            hadError = true;
          }
          process.stdout.write(d);
          return null;
        });
        return result.then(function() {
          if (hadError) {
            throw new Error("Cannot checkout h5-ide-build");
          }
          return true;
        });
      };
    },
    preCommit: function() {
      var commitData, move, option;
      logTask("Pre-commit");
      move = util.runCommand("mv", ["h5-ide-build/.git", "deploy/.git"], {});
      if (fs.existsSync("./h5-ide-build/.gitignore")) {
        move = move.then(function() {
          return util.runCommand("mv", ["h5-ide-build/.gitignore", "deploy/.gitignore"], {});
        });
      }
      option = {
        cwd: process.cwd() + "/deploy"
      };
      commitData = "";
      return move.then(function() {
        util.deleteFolderRecursive(process.cwd() + "/h5-ide-build");
        return util.runCommand("git", ["add", "-A"], option);
      }).then(function() {
        return util.runCommand("git", ["commit", "-m", "pre-" + (ideversion.version())], option, function(d) {
          commitData += d;
          return null;
        });
      }).then(function() {
        if (commitData[0] === "#") {
          console.log(commitData);
        } else {
          commitData = commitData.split("\n");
          console.log(commitData[0]);
          console.log(commitData[1]);
        }
        return true;
      });
    },
    fileVersion: function() {
      var fileData, listFile, noramlize, urlRegex, versions;
      logTask("Getting all files version");
      fileData = "";
      listFile = util.runCommand("git", ["ls-files", "-s"], {
        cwd: process.cwd() + "/deploy"
      }, function(d, type) {
        if (type === "out") {
          fileData += d;
        }
        return null;
      });
      urlRegex = /(\="|\='|url\('|url\(")([^'":]+?\/[^'"]+?\/[^'"?]+?)("|')/g;
      noramlize = /\\/g;
      versions = {};
      return listFile.then(function() {
        var entry, line, _i, _len, _ref, _results;
        _ref = fileData.split("\n");
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          line = entry.split(/\s+?/);
          if (line[3]) {
            versions[line[3].replace(noramlize, "/")] = line[1].substr(0, 8);
          }
          _results.push(null);
        }
        return _results;
      }).then(function() {
        var d;
        d = Q.defer();
        gulp.src(["./deploy/*.html", "./deploy/assets/css/*.css"], {
          base: process.cwd() + "/deploy"
        }).pipe(es.through(function(f) {
          var cwd, newContent;
          cwd = path.resolve(process.cwd(), "./deploy");
          newContent = f.contents.toString("utf8").replace(urlRegex, function(match, p1, p2, p3) {
            var p, version;
            p = path.resolve(path.dirname(f.path), p2).replace(cwd, "");
            if (p[0] === "/" || p[0] === "\\") {
              p = p.replace(/\/|\\/, "");
            }
            version = versions[p];
            if (GLOBAL.gulpConfig.verbose) {
              console.log(p, version);
            }
            if (version) {
              return p1 + p2 + ("?v=" + version) + p3;
            } else {
              return match;
            }
          });
          f.contents = new Buffer(newContent);
          this.emit("data", f);
          return null;
        })).pipe(gulp.dest("./deploy")).on("end", end(d));
        return d.promise;
      }).then(function() {
        var buster, d, jsV, key, l, value;
        jsV = {};
        for (key in versions) {
          value = versions[key];
          l = key.length;
          if (key[l - 3] === "." && key[l - 2] === "j" && key[l - 1] === "s") {
            jsV[key] = value;
          }
        }
        buster = "window.FileVersions=" + JSON.stringify(jsV) + ";\n";
        d = Q.defer();
        gulp.src("./deploy/**/config.js").pipe(es.through(function(f) {
          f.contents = new Buffer(buster + f.contents.toString("utf8"));
          return this.emit("data", f);
        })).pipe(gulp.dest("./deploy")).on("end", end(d));
        return d.promise;
      });
    },
    logDeployInDevRepo: function() {
      logTask("Commit IdeVersion in h5-ide");
      ideversion.read(true);
      return util.runCommand("git", ["commit", "-m", '"Deploy ' + ideversion.version() + '"', "package.json"]);
    },
    finalCommit: function() {
      var devRepoV, option, task;
      logTask("Final Commit");
      option = {
        cwd: process.cwd() + "/deploy"
      };
      devRepoV = "HEAD";
      task = util.runCommand("git", ["rev-parse", "HEAD"], void 0, function(d) {
        devRepoV = d;
        return null;
      });
      return task.then(function() {
        return util.runCommand("git", ["add", "-A"], option);
      }).then(function() {
        return util.runCommand("git", ["commit", "-m", "" + (ideversion.version()) + " ; DevRepo: MadeiraCloud/h5-ide@" + devRepoV], option);
      }).then(function() {
        if (GLOBAL.gulpConfig.autoPush) {
          console.log("[ " + gutil.colors.bgBlue.white("Pushing to Remote") + " ]");
          console.log(gutil.colors.bgYellow.black("  AutoPush might be slow, you can always kill the task at this moment. "));
          console.log(gutil.colors.bgYellow.black("  Then manually git-push `./deploy`. You can delete `./deploy` after git-pushing. "));
          return util.runCommand("git", ["push", "-v", "--progress", "-f"], option, stdRedirect);
        } else {
          console.log(gutil.colors.bgYellow.black("  AutoPush is disabled. Please manually git-push `./deploy`. "));
          console.log(gutil.colors.bgYellow.black("  You can delete `./deploy` after pushing. "));
          return true;
        }
      }).then(function() {
        if (GLOBAL.gulpConfig.autoPush) {
          if (!util.deleteFolderRecursive(process.cwd() + "/deploy")) {
            console.log(gutil.colors.bgYellow.black("  Cannot delete ./deploy. You should manually delete ./deploy before next deploying.  "));
          }
        }
        return true;
      });
    },
    test: function(qaMode) {
      return function() {
        var p, result, testserver;
        p = qaMode ? "./qa" : "./deploy";
        testserver = server.create(p, 3010, false, false);
        logTask("Starting automated test");
        result = unittest();
        if (result) {
          return result.then(function() {
            testserver.close();
            return true;
          });
        } else {
          return true;
        }
      };
    }
  };

  module.exports = {
    build: function(mode) {
      var debugMode, deploy, isPublic, outputPath, qaMode, releaseVersion, repoBranch, tasks;
      ideversion.read();
      repoBranch = "master";
      if (mode === "debug") {
        repoBranch = "develop";
      }
      if (mode === "public") {
        repoBranch = "public";
      }
      if (mode === "public") {
        mode = "release";
        isPublic = true;
      }
      if (mode === "release") {
        releaseVersion = GLOBAL.gulpConfig.version.split(".");
        releaseVersion.length = 3;
        GLOBAL.gulpConfig.version = releaseVersion.join(".");
      }
      deploy = mode !== "qa";
      debugMode = mode === "qa" || mode === "debug";
      outputPath = mode === "qa" ? "./qa" : void 0;
      qaMode = mode === "qa";
      tasks = [Tasks.checkGitVersion, Tasks.cleanRepo, Tasks.copyAssets, Tasks.copyJs, Tasks.compileLangSrc, Tasks.compileCoffee(debugMode)];
      if (isPublic) {
        tasks.push(Tasks.removeRedirectForPublic);
      }
      tasks = tasks.concat([Tasks.compileTemplate, Tasks.processHtml, Tasks.concatJS(debugMode, outputPath), Tasks.removeBuildFolder, Tasks.test(qaMode)]);
      if (!qaMode) {
        tasks = tasks.concat([Tasks.fetchRepo(repoBranch), Tasks.preCommit, Tasks.fileVersion, Tasks.logDeployInDevRepo, Tasks.finalCommit]);
      }
      return tasks.reduce(Q.when, true).then(function() {
        console.log(gutil.colors.bgBlue.white("\n [Build Succeed] ") + "\n");
        return true;
      }, function(p) {
        console.log("[", gutil.colors.bgRed.white("Build Task Aborted"), "]", p);
        throw new Error("\n");
      });
    }
  };

}).call(this);
