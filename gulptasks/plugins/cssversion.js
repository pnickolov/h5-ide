(function() {
  var CssVersionRegex, es, fs, htmlModify, path;

  es = require("event-stream");

  path = require("path");

  fs = require("fs");

  CssVersionRegex = /(href="|')([^'"]+)\/([^.]+.css)("|')/g;

  htmlModify = function(file) {
    var data, modified;
    modified = false;
    data = file.contents.toString("utf8").replace(CssVersionRegex, (function(_this) {
      return function(match, p1, p2, p3, p4) {
        if (_this.cssVersion[p3]) {
          modified = true;
          return p1 + p2 + "/" + p3 + "?v=" + _this.cssVersion[p3] + p4;
        } else {
          return match;
        }
        return null;
      };
    })(this));
    if (modified) {
      file.contents = new Buffer(data);
    }
    this.emit("data", file);
    return null;
  };

  module.exports = function(cssVersion) {
    var pipe;
    pipe = es.through(htmlModify);
    pipe.cssVersion = cssVersion || {};
    return pipe;
  };

}).call(this);
