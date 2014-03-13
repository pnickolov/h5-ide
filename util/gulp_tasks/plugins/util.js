(function() {
  var Q, fs, gutil, notifier, spawn, util;

  gutil = require("gulp-util");

  notifier = require("node-notifier");

  fs = require("fs");

  spawn = require('child_process').spawn;

  Q = require("q");

  util = {
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
      if (GLOBAL.gulpConfig.enbaleNotifier && msg) {
        notifier.notify({
          title: "IDE Gulp",
          message: msg
        }, function() {});
      }
      return null;
    },
    compileTitle: function(extra, printTime) {
      var time, title;
      if (printTime == null) {
        printTime = true;
      }
      time = printTime ? " @" + (new Date()).toLocaleTimeString() : "";
      title = "[" + gutil.colors.green("Compile" + time) + "]";
      if (extra) {
        title += " " + gutil.colors.inverse(extra);
      }
      return title;
    },
    deleteFolderRecursive: function(path) {
      var curPath, file, index, _i, _len, _ref;
      if (!fs.existsSync(path)) {
        return;
      }
      _ref = fs.readdirSync(path) || [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        file = _ref[index];
        curPath = path + "/" + file;
        if (fs.lstatSync(curPath).isDirectory()) {
          util.deleteFolderRecursive(curPath);
        } else {
          fs.unlinkSync(curPath);
        }
      }
      fs.rmdirSync(path);
      return null;
    },
    runCommand: function(command, args, options, handlers) {
      var d, onData, process;
      d = Q.defer();
      process = spawn(command, args, options);
      handlers = handlers || {};
      onData = handlers.apply && handlers.call ? handlers : handlers.onData;
      process.on("exit", function() {
        return d.resolve();
      });
      if (handlers.onError) {
        process.on("error", handlers.onError);
      }
      if (onData) {
        process.stderr.on("data", function(d) {
          return onData(d.toString("utf8"), "error");
        });
        process.stdout.on("data", function(d) {
          return onData(d.toString("utf8"), "out");
        });
      }
      return d.promise;
    }
  };

  module.exports = util;

}).call(this);
