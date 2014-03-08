(function() {
  var build, coffee, confCompile, es, gulp, handlebars, include, langsrc;

  gulp = require("gulp");

  es = require("event-stream");

  include = require("./plugins/include");

  langsrc = require("./plugins/langsrc");

  coffee = require("gulp-coffee");

  confCompile = require("./plugins/conditional");

  handlebars = require("./plugins/handlebars");

  build = function(debugMode) {
    gulp.src(["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"]).pipe(gulp.dest("./build/assets/"));
    gulp.src(["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"]).pipe(gulp.dest("./build/assets/"));
    gulp.src(["./src/nls/lang-source.coffee"]).pipe(langsrc("./build", false));
    gulp.src(["./src/**/*.coffee"]).pipe(confCompile(true)).pipe(coffee()).pipe(gulp.dest("./build"));
    gulp.src(["./src/**/*.partials", "./src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html"]).pipe(confCompile(true)).pipe(handlebars()).pipe(gulp.dest("./build"));
    gulp.src(["./src/*.html"]).pipe(confCompile(true)).pipe(include()).pipe(gulp.dest("./build"));
    return null;
  };

  module.exports = {
    build: build
  };

}).call(this);
