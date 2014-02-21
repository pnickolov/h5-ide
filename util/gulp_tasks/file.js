// Generated by CoffeeScript 1.6.2
var coffee, coffeeErrorPrinter, coffeelint, coffeelintOptions, compile, compileCoffeeOnly, compileIgnorePath, endsWith, fileTaskDistribute, gulp, gutil, jshint, path, reporter, through2, verbose, walk, watch;

gulp = require("gulp");

gutil = require("gulp-util");

path = require("path");

walk = require("walkdir");

coffee = require("gulp-coffee");

coffeelint = require("gulp-coffeelint");

jshint = require("gulp-jshint");

reporter = require('./reporter');

through2 = require("through2");

coffeelintOptions = {
  indentation: {
    level: "ignore"
  },
  no_tabs: {
    level: "ignore"
  },
  max_line_length: {
    level: "ignore"
  }
};

compileIgnorePath = /.src.(test|vender|ui)/;

compileCoffeeOnly = /.src.(service|model)/;

verbose = true;

fileTaskDistribute = function(file) {
  var compileOnly, fileDir, src;

  if (endsWith(file, ".coffee")) {
    console.log("[Compile] " + file.replace(process.cwd(), "."));
    compileOnly = file.match(compileCoffeeOnly);
    fileDir = path.dirname(file);
    src = gulp.src(file);
    if (!compileOnly) {
      src.pipe(coffeelint(void 0, coffeelintOptions));
    }
    src.pipe(coffee({
      bare: true
    }).on("error", coffeeErrorPrinter)).pipe(gulp.dest(fileDir));
    if (!compileOnly) {
      return src.pipe(jshint()).pipe(reporter());
    }
  } else {

  }
};

endsWith = function(string, pattern) {
  var idx, startIdx;

  if (string.length < pattern.length) {
    return false;
  }
  idx = 0;
  startIdx = string.length - pattern.length;
  while (idx < pattern.length) {
    if (string[startIdx + idx] !== pattern[idx]) {
      return false;
    }
    ++idx;
  }
  return true;
};

coffeeErrorPrinter = function(error) {
  console.log(gutil.colors.red.bold("\n[CoffeeError]"), error.message.replace(process.cwd(), "."));
  this.pause();
  return null;
};

watch = function() {
  var changeHandler, chokidar, watcher;

  gutil.log(gutil.colors.bgBlue(" Watching file changes... "));
  chokidar = require("chokidar");
  watcher = chokidar.watch("./src/", {
    usePolling: false,
    useFsEvents: true,
    ignoreInitial: true,
    ignored: /([\/\\]\.)|src.(assets|test|vender)/
  });
  changeHandler = function(path) {
    if (verbose) {
      console.log("[Change]", path);
    }
    fileTaskDistribute(path);
    return null;
  };
  watcher.on("add", changeHandler);
  watcher.on("change", changeHandler);
  return null;
};

compile = function() {
  return null;
};

module.exports = {
  watch: watch,
  compile: compile
};
