(function() {
  var ReplaceFunc, ReplaceRegex, es, stringType;

  es = require("event-stream");

  stringType = typeof "";

  ReplaceRegex = /#{(.+?)}/g;

  ReplaceFunc = function(match, p1) {
    if (GLOBAL.gulpConfig.hasOwnProperty(p1)) {
      return GLOBAL.gulpConfig[p1];
    } else {
      return match;
    }
  };

  module.exports = function() {
    return es.through(function(f) {
      if (typeof f.strings === stringType) {
        f.contents = new Buffer(f.strings.replace(ReplaceRegex, ReplaceFunc));
        f.strings = null;
      }
      return this.emit("data", f);
    });
  };

}).call(this);
