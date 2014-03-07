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
    var data, modified;
    modified = false;
    data = file.contents.toString("utf8").replace(ReplaceRegex, function(match, includePath) {
      var p;
      p = path.resolve(file.path, includePath);
      if (!fs.existsSync(p)) {
        console.log("[Include Error] Cannot find : " + match);
        return match;
      }
      modified = true;
      return fs.readFileSync(p, ReadOption);
    });
    if (modified) {
      file.contents = new Buffer(data);
    }
    this.emit("data", file);
    return null;
  };

  module.exports = function() {
    return es.through(include);
  };

}).call(this);
