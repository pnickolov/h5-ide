(function() {
  var HandlebarsOptions, compile, compileHbs, compilePartials, es, gutil, handlebars, path, tryCompile, util;

  es = require("event-stream");

  handlebars = require("handlebars");

  path = require("path");

  gutil = require("gulp-util");

  util = require("./util");

  HandlebarsOptions = {
    knownHelpersOnly: true,
    knownHelpers: {
      i18n: true,
      ifCond: true,
      nl2br: true,
      emptyStr: true,
      timeStr: true,
      plusone: true,
      tolower: true,
      UTC: true,
      breaklines: true,
      is_service_error: true,
      is_unmanaged: true,
      city_code: true,
      city_area: true,
      convert_string: true,
      is_vpc_disabled: true,
      vpc_list: true,
      vpc_sub_item: true
    }
  };

  compile = function(file) {
    if (path.extname(file.path) === ".partials") {
      compilePartials(file);
    } else {
      compileHbs(file);
    }
    this.emit("data", file);
    return null;
  };

  tryCompile = function(data, file) {
    var e, result;
    try {
      result = handlebars.precompile(data, HandlebarsOptions);
    } catch (_error) {
      e = _error;
      console.log(gutil.colors.red.bold("\n[TplError]"), file.relative);
      console.log(e.message + "\n");
      util.notify("Error occur when compiling " + file.relative);
      return "";
    }
    return result;
  };

  compilePartials = function(file) {
    var content, data, i, idx, n, namespace, namespaces, newData, result, space, _i, _len;
    content = file.contents.toString("utf8");
    data = content.split(/\<!--\s*\{\{\s*(.*)\s*\}\}\s*--\>/ig);
    newData = "";
    namespace = {};
    i = 1;
    while (i < data.length) {
      result = tryCompile(data[i + 1], file);
      if (!result) {
        newData = "";
        break;
      }
      newData += ("TEMPLATE." + data[i] + "=") + result + ";\n\n";
      namespaces = data[i].split(".");
      space = namespace;
      for (idx = _i = 0, _len = namespaces.length; _i < _len; idx = ++_i) {
        n = namespaces[idx];
        if (idx < namespaces.length - 1) {
          if (!space[n]) {
            space[n] = {};
          }
          space = space[n];
        }
      }
      i += 2;
    }
    if (newData) {
      console.log(util.compileTitle(), file.relative);
    }
    newData = "define(['handlebars'], function(Handlebars){ var TEMPLATE=" + JSON.stringify(namespace) + ";\n\n" + newData + "return TEMPLATE; });";
    file.contents = new Buffer(newData, "utf8");
    file.path = gutil.replaceExtension(file.path, ".js");
    return null;
  };

  compileHbs = function(file) {
    var newData;
    newData = tryCompile(file.contents.toString("utf8"), file);
    if (newData) {
      console.log(util.compileTitle(), file.relative);
    }
    newData = "define(['handlebars'], function(Handlebars){ var TEMPLATE = " + newData + "; return TEMPLATE; });";
    file.contents = new Buffer(newData, "utf8");
    file.path = gutil.replaceExtension(file.path, ".js");
    return null;
  };

  module.exports = function() {
    return es.through(compile);
  };

}).call(this);
