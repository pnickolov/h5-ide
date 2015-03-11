var DefaultLocale, LocalePathMapping, LocaleValidator, Q, build, coffee, coffeelint, deepExtend, es, gulp, gutil, lintReporter, pipeline, rPath, recursive, set, util, vm, write;

util = require("./util");

es = require("event-stream");

vm = require("vm");

deepExtend = require('deep-extend');

gulp = require("gulp");

gutil = require("gulp-util");

coffee = require("gulp-coffee");

Q = require("q");

coffeelint = require("gulp-coffeelint");

lintReporter = require('./reporter');

DefaultLocale = "en";

LocalePathMapping = {
  "en": "nls/en-us/lang.js",
  "zh": "nls/zh-cn/lang.js"
};

LocaleValidator = {
  en: function(res) {
    var ch, idx, key, val;
    for (key in res) {
      val = res[key];
      if (typeof val === "string") {
        idx = val.length - 1;
        while (idx >= 0) {
          ch = val.charCodeAt(idx);
          if (ch <= 0 || ch >= 0xff) {
            console.log(gutil.colors.red.bold("[LangSrc Error]"), "Invalid content for 'en': { " + key + " : " + val + " }");
            return false;
          }
          --idx;
        }
      } else {
        if (LocaleValidator.en(val) === false) {
          return false;
        }
      }
    }
    return true;
  }
};

set = function(object, paths, key, val) {
  var i, idx, len, p;
  for (idx = i = 0, len = paths.length; i < len; idx = ++i) {
    p = paths[idx];
    object = object[p] || (object[p] = {});
  }
  object[key] = val;
};

rPath = [];

recursive = function(data, result, lastPath) {
  var key, val;
  for (key in data) {
    val = data[key];
    if (typeof val === "string") {
      set(result[key] || (result[key] = {}), rPath, lastPath, val || data[DefaultLocale]);
    } else {
      if (lastPath) {
        rPath.push(lastPath);
        recursive(val, result, key);
        rPath.length = rPath.length - 1;
      } else {
        recursive(val, result, key);
      }
    }
  }
};

write = function(dest, data) {
  var lang, path, result, val, validator, writepipeline;
  result = {};
  rPath = [];
  recursive(data, result);
  writepipeline = es.through();
  writepipeline.pipe(gulp.dest(dest));
  for (lang in result) {
    val = result[lang];
    validator = LocaleValidator[lang];
    if (validator && validator(val) === false) {
      continue;
    }
    path = LocalePathMapping[lang];
    if (!path) {
      console.log(gutil.colors.yellow.bold("\n[LangSrc]", "Language " + lang + "'s path is not specified."));
      continue;
    }
    writepipeline.emit("data", new gutil.File({
      path: path,
      relative: path,
      contents: new Buffer("define(" + JSON.stringify(val, void 0, 4) + ")")
    }));
  }
  writepipeline.emit("end");
};

build = function(dest, shouldLog) {
  var ctx, d, p, result;
  if (dest == null) {
    dest = "./src";
  }
  if (shouldLog == null) {
    shouldLog = true;
  }
  ctx = vm.createContext({
    module: {}
  });
  d = Q.defer();
  result = {};
  p = gulp.src(["./src/nls/*.coffee"], {
    cwdbase: true
  });
  if (shouldLog) {
    p = p.pipe(coffeelint(void 0, {
      no_tabs: {
        level: "ignore"
      },
      max_line_length: {
        level: "ignore"
      }
    })).pipe(lintReporter());
  }
  p.pipe(coffee({
    bare: true
  })).pipe(es.through(function(f) {
    var e;
    try {
      vm.runInContext(f.contents.toString("utf8"), ctx);
      return deepExtend(result, ctx.module.exports);
    } catch (_error) {
      e = _error;
      return console.log(gutil.colors.red.bold("\n[LangSrc]"), "Invalid language content @" + f.path, e);
    }
  }));
  p.on("end", function() {
    write(dest, result);
    return d.resolve();
  });
  return d.promise;
};

pipeline = function() {
  var cache;
  cache = {};
  return es.through(function(file) {
    var utf8Content;
    if (GLOBAL.gulpConfig.enableCache) {
      utf8Content = file.contents.toString("utf8");
      if (cache[file.path] === utf8Content) {
        return;
      }
      cache[file.path] = utf8Content;
    }
    console.log(util.compileTitle("Language"), file.relative);
    return build();
  });
};

module.exports = {
  build: build,
  pipeline: pipeline
};
