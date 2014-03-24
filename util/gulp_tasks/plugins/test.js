(function() {
  var Q, gutil;

  Q = require("q");

  gutil = require("gulp-util");

  module.exports = function(url) {
    var e, zombie;
    try {
      zombie = require("zombie");
    } catch (_error) {
      e = _error;
      console.log(gutil.colors.bgYellow.black("Cannot find zombie. Automated test is not disabled."));
      return false;
    }
    return true;
  };

}).call(this);
