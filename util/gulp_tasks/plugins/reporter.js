(function() {
  var es, gutil, problemSign, reporter, reporterWrap, stringLength, table, transform;

  table = require("text-table");

  gutil = require("gulp-util");

  es = require("event-stream");

  stringLength = function(str) {
    return gutil.colors.stripColor(str).length;
  };

  problemSign = process.platform === "win32" ? "x " : "✖ ";

  transform = function(el, i) {
    var err;
    err = el.error || el;
    return ["", gutil.colors.yellow("line " + (err.line || err.lineNumber)), gutil.colors.yellow(err.character ? "col " + err.character : ""), gutil.colors.inverse("(" + (err.code || err.rule) + ")") + " " + gutil.colors.blue(err.reason || err.message)];
  };

  reporter = function(fileName, title, result) {
    var ret, total;
    total = result.length;
    if (total > 0) {
      title = gutil.colors.red.bold("[" + title + " " + problemSign + total + "] ") + gutil.colors.underline(fileName);
      ret = title + "\n" + table(result.map(transform), {
        stringLength: stringLength
      });
      console.log(ret + "\n");
    }
    return null;
  };

  reporterWrap = function(file) {
    var p;
    p = file.path.replace(process.cwd(), "");
    if (file.coffeelint && !file.coffeelint.success) {
      reporter(p, "CoffeeLint", file.coffeelint.results);
    }
    if (file.jshint && !file.jshint.success) {
      reporter(p, "JsHint", file.jshint.results);
    }
    return this.emit('data', file);
  };

  module.exports = function() {
    return es.through(reporterWrap);
  };

}).call(this);
