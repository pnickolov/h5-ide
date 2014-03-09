(function() {
  var fs, pkgInfo, save, version;

  fs = require("fs");

  pkgInfo = null;

  version = function() {
    var date;
    if (pkgInfo) {
      return pkgInfo.version;
    }
    pkgInfo = JSON.parse(fs.readFileSync("./package.json", {
      encoding: 'utf8'
    }));
    version = pkgInfo.version.split(".");
    version[1] = parseInt(version[1], 10) + 1;
    pkgInfo.version = version.join(".");
    date = new Date();
    date = [date.getFullYear(), date.getMonth() + 1, date.getDate()];
    if (date[1] < 10) {
      date[1] = "0" + date[1];
    }
    if (date[2] < 10) {
      date[2] = "0" + date[2];
    }
    GLOBAL.gulpConfig.version = pkgInfo.version + (" (" + (date.join('')) + ")");
    return GLOBAL.gulpConfig.version;
  };

  save = function() {
    if (!pkgInfo) {
      version();
    }
    fs.writeFileSync("./package.json", JSON.stringify(pkgInfo, null, 2));
    return null;
  };

  module.exports = {
    version: version,
    save: save
  };

}).call(this);
