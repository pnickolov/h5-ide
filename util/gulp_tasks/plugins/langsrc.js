(function() {
  var base, buildLangSrc, cacheForLang, cached, coffee, compileImmediately, compiled, cwd, deepExtend, es, gulp, gutil, langCache, langDest, langShouldLog, langWrite, langemitError, pipeline, util, vm;

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

  langemitError = pipeline = langDest = langShouldLog = null;

  compiled = false;

  compileImmediately = function() {
    return compiled = true;
  };

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
    langShouldLog = shouldLog;
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
      cwd = file.cwd;
      base = file.base;
      pipeline.setMaxListeners(100);
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
    writeFile = function(files) {
      var file, _i, _len;
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        pipeline.emit("data", new gutil.File({
          cwd: cwd,
          base: base,
          path: file.path,
          contents: new Buffer(file.contents)
        }));
      }
      pipeline.emit("end");
      if (langShouldLog) {
        console.log(util.compileTitle(), "Lang-file Compiled Done");
      }
      return null;
    };
    if (buildLangSrc(writeFile, cacheForLang) === false && langemitError) {
      pipeline.emit("error", "LangSrc build failure");
    }
    compiled = true;
    return null;
  };

  module.exports = {
    langCache: langCache,
    langWrite: langWrite,
    compileImmediately: compileImmediately
  };

}).call(this);
