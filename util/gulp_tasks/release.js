(function() {
  var build, coffee, confCompile, es, gulp, gutil, handlebars, include, langsrc, logCoffee, logTask, util;

  gulp = require("gulp");

  gutil = require("gulp-util");

  es = require("event-stream");

  coffee = require("gulp-coffee");

  include = require("./plugins/include");

  langsrc = require("./plugins/langsrc");

  confCompile = require("./plugins/conditional");

  handlebars = require("./plugins/handlebars");

  util = require("./plugins/util");

  logTask = function(msg) {
    console.log("[", gutil.colors.bgBlue.white(msg), "]");
    return null;
  };

  logCoffee = function() {
    return es.through(function(f) {
      if (GLOBAL.gulpConfig.verbose) {
        console.log(util.compileTitle(f.extra), "" + f.relative);
      }
      this.emit("data", f);
      return null;
    });
  };

  build = function(debugMode) {
    logTask("Copying Assets");
    gulp.src(["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"]).pipe(gulp.dest("./build/assets/"));
    logTask("Copying Js Files");
    gulp.src(["./src/js/*.js"]).pipe(gulp.dest("./build/js"));
    gulp.src(["./src/ui/*.js"]).pipe(gulp.dest("./build/ui"));
    gulp.src(["./src/vender/**/*"]).pipe(gulp.dest("./build/vender"));
    logTask("Compiling lang-source");
    gulp.src(["./src/nls/lang-source.coffee"]).pipe(langsrc("./build", false, GLOBAL.gulpConfig.verbose));
    logTask("Compiling coffees");
    gulp.src(["./src/**/*.coffee", "!src/test/**/*"]).pipe(confCompile(true)).pipe(coffee()).pipe(logCoffee()).pipe(gulp.dest("./build"));
    logTask("Compiling templates");
    gulp.src(["./src/**/*.partials", "./src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html"]).pipe(confCompile(true)).pipe(handlebars(GLOBAL.gulpConfig.verbose)).pipe(gulp.dest("./build"));
    logTask("Copying ./src/*.html");
    gulp.src(["./src/*.html"]).pipe(confCompile(true)).pipe(include()).pipe(gulp.dest("./build"));
    return null;
  };

  module.exports = {
    build: build
  };

}).call(this);
