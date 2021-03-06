var ExcludeRjsPluginRegex, IgnoreCheckPath, PathTransform, gutil, path, transformedPath;

path = require("path");

gutil = require("gulp-util");

IgnoreCheckPath = {
  "ui/MC.template.js": true
};

PathTransform = {
  "js/": "lib/"
};

ExcludeRjsPluginRegex = /^[^\/!]+!/;

transformedPath = function(p) {
  var key, value;
  p = p.replace(ExcludeRjsPluginRegex, "");
  for (key in PathTransform) {
    value = PathTransform[key];
    if (p.indexOf(key) === 0) {
      return p.replace(key, value);
    }
  }
  return p;
};

module.exports = function(info) {
  var duplicateTest, hasDuplicate, hasInvalidInclude, i, idx, item, j, len, len1, message, ref, res, s, source, target;
  info = info.replace(/\r\n/g, "\n").replace(/\\/g, "/");
  if (info[0] === "\n") {
    info = info.replace("\n", "");
  }
  info = info.split("\n\n");
  duplicateTest = {};
  hasDuplicate = false;
  hasInvalidInclude = false;
  for (idx = i = 0, len = info.length; i < len; idx = ++i) {
    item = info[idx];
    item = item.split("\n----------------\n");
    target = path.dirname(item[0]) + "/";
    if (idx > 0) {
      console.log("");
    }
    console.log(gutil.colors.green(target) + item[0].replace(target, ""));
    console.log("----------------");
    ref = item[1].split("\n");
    for (j = 0, len1 = ref.length; j < len1; j++) {
      source = ref[j];
      if (!source) {
        continue;
      }
      message = "";
      if (source.lastIndexOf(".css") + 4 !== source.length) {
        if (duplicateTest[source]) {
          hasDuplicate = true;
          message = gutil.colors.bgRed.white("Duplicated") + " ";
        }
        duplicateTest[source] = true;
      }
      if (IgnoreCheckPath[source]) {
        message += source;
      } else {
        s = transformedPath(source);
        if (s.indexOf(target) === 0) {
          res = s.replace(target, "");
          message += gutil.colors.green(source.replace(res, "")) + res;
        } else {
          hasInvalidInclude = true;
          message += gutil.colors.bgRed.white("Invalid") + " " + source;
        }
      }
      console.log(message);
    }
  }
  return !(hasDuplicate || hasInvalidInclude);
};
