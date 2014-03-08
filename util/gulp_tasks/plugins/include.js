(function() {
  var ReadOption, ReplaceRegex, es, fs, include, path;

  es = require("event-stream");

  path = require("path");

  fs = require("fs");

  ReplaceRegex = /<!--\s+{{([^}]+)}}\s+-->/g;

  ReadOption = {
    encoding: "utf8"
  };

  include = function(file) {
    file.strings = file.contents.toString("utf8").replace(ReplaceRegex, function(match, includePath) {
      var p;
      p = path.resolve(path.dirname(file.path), includePath);
      if (!fs.existsSync(p)) {
        console.log("[Include Error] Cannot find : " + match);
        return match;
      }
      return fs.readFileSync(p, ReadOption);
    });
    file.contents = null;
    this.emit("data", file);
    return null;
  };

  module.exports = function() {
    return es.through(include);
  };

}).call(this);
