(function() {
  var base, buildLangSrc, cacheForLang, cached, coffee, compiled, cwd, deepExtend, es, gulp, gutil, langCache, langDest, langWrite, langemitError, pipeline, util, vm;

  util = require("./util");

  cached = require("./cached");

  es = require("event-stream");

  vm = require("vm");

  deepExtend = require('deep-extend');

  gulp = require("gulp");

  gutil = require("gulp-util");

  coffee = require("gulp-coffee");

  buildLangSrc = require("./lang");

  cacheForLang = {};

  cwd = base = "";

  langemitError = pipeline = langDest = null;

  compiled = false;

  langCache = function(dest, useCache, shouldLog, emitError) {
    var startPipeline;
    if (dest == null) {
      dest = ".";
    }
    if (useCache == null) {
      useCache = true;
    }
    if (shouldLog == null) {
      shouldLog = true;
    }
    if (emitError == null) {
      emitError = false;
    }
    if (useCache) {
      startPipeline = cached(coffee());
    } else {
      startPipeline = coffee();
    }
    cacheForLang = {};
    langDest = dest;
    langemitError = emitError;
    pipeline = startPipeline.pipe(es.through(function(file) {
      var ctx, e;
      ctx = vm.createContext({
        module: {}
      });
      try {
        vm.runInContext(file.contents.toString("utf8"), ctx);
        deepExtend(cacheForLang, ctx.module.exports);
      } catch (_error) {
        e = _error;
        console.log(e);
        console.log(gutil.colors.red.bold("\n[LangSrc]"), "lang-source.coffee content is invalid");
      }
      if (shouldLog) {
        console.log(util.compileTitle(), file.relative);
      }
      cwd = file.cwd;
      base = file.base;
      pipeline.pipe(gulp.dest(langDest));
      if (compiled) {
        langWrite();
      }
      return null;
    }));
    return startPipeline;
  };

  langWrite = function() {
    var writeFile;
    writeFile = function(p1, p2) {
      pipeline.emit("data", new gutil.File({
        cwd: cwd,
        base: base,
        path: p1,
        contents: new Buffer(p2)
      }));
      compiled = true;
      return null;
    };
    if (buildLangSrc(writeFile, cacheForLang) === false && langemitError) {
      return pipeline.emit("error", "LangSrc build failure");
    }
  };

  module.exports = {
    langCache: langCache,
    langWrite: langWrite
  };

}).call(this);
