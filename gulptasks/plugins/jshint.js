(function() {
  var es, formatOutput, gutil, jshint, jshintGlobals, jshintOption, problemSign;

  es = require("event-stream");

  gutil = require("gulp-util");

  jshint = require('jshint').JSHINT;

  jshintGlobals = {};

  jshintOption = {
    "-W099": true,
    "-W041": true,
    "-W030": true
  };

  problemSign = process.platform === "win32" ? "x " : "✖ ";

  formatOutput = function(success, file) {
    var data, filePath, results;
    if (success) {
      return {
        success: true
      };
    }
    filePath = file.path || 'stdin';
    results = jshint.errors.map(function(err) {
      if (!err) {
        return;
      }
      return {
        file: filePath,
        error: err
      };
    });
    data = [jshint.data()];
    data[0].file = filePath;
    return {
      success: false,
      results: results.filter(function(err) {
        return err;
      }),
      data: data
    };
  };

  module.exports = function() {
    return es.through(function(file) {
      var e, str, success;
      if (file.isNull() || file.isStream()) {
        return this.emit("data", file);
      }
      str = file.contents.toString('utf8');
      try {
        success = jshint(str, jshintOption, jshintGlobals);
      } catch (_error) {
        e = _error;
        console.log(gutil.colors.red.bold("[JsHint " + problemSign + " 999]"), gutil.colors.underline(file.path));
        console.log("Too many jshint error.");
        this.emit("data", file);
      }
      file.jshint = formatOutput(success, file);
      this.emit("data", file);
      return null;
    });
  };

}).call(this);
