(function() {
  var es;

  es = require("event-stream");

  module.exports = function(nextPipe) {
    var newCache, pipeline;
    if (!GLOBAL.gulpConfig.enableCache) {
      return nextPipe;
    }
    newCache = {};
    pipeline = es.through(function(file) {
      var utf8Content;
      if (newCache[file.path]) {
        utf8Content = file.contents.toString("utf8");
        if (newCache[file.path] === utf8Content) {
          if (GLOBAL.gulpConfig.verbose) {
            console.log("[Cached]", file.path);
          }
          return;
        }
      }
      if (!utf8Content) {
        utf8Content = file.contents.toString("utf8");
      }
      newCache[file.path] = utf8Content;
      this.emit("data", file);
      return null;
    });
    pipeline.pipe(nextPipe);
    return pipeline;
  };

}).call(this);
