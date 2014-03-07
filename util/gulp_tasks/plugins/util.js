(function() {
  var gutil, notifier;

  gutil = require("gulp-util");

  notifier = require("node-notifier");

  module.exports = {
    log: function(e) {
      return console.log(e);
    },
    noop: function() {},
    cwd: process.cwd(),
    endsWith: function(string, pattern) {
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
    },
    notify: function(msg) {
      if (GLOBAL.gulpConfig.enbaleNotifier) {
        notifier.notify({
          title: "IDE Gulp",
          message: msg
        }, function() {});
      }
      return null;
    },
    compileTitle: function(extra) {
      var title;
      title = "[" + gutil.colors.green("Compile @" + ((new Date()).toLocaleTimeString())) + "]";
      if (extra) {
        title += " " + gutil.colors.inverse(extra);
      }
      return title;
    }
  };

}).call(this);
