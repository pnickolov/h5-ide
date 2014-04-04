(function() {
  var DefaultKnownHelpers, HandlebarsOptions, HasRead, IgnoreSyntax, coffee, compile, compileHbs, compilePartials, compiler, es, fs, gutil, handlebars, path, readHelperFile, tryCompile, util;

  es = require("event-stream");

  handlebars = require("handlebars");

  path = require("path");

  fs = require("fs");

  gutil = require("gulp-util");

  coffee = require("gulp-coffee");

  util = require("./util");

  DefaultKnownHelpers = {
    is_service_error: true,
    is_unmanaged: true,
    city_code: true,
    city_area: true,
    convert_string: true,
    is_vpc_disabled: true,
    vpc_list: true,
    vpc_sub_item: true
  };

  HandlebarsOptions = {
    knownHelpersOnly: true,
    knownHelpers: {}
  };

  HasRead = false;

  IgnoreSyntax = new Buffer("<!DOCTYPE HTML>");

  readHelperFile = function() {
    var file, pipeline;
    if (HasRead) {
      return;
    }
    file = fs.readFileSync("./src/lib/handlebarhelpers.coffee");
    pipeline = es.through(function(f) {});
    pipeline.pipe(coffee()).pipe(es.through(function(f) {
      var helpers, i;
      helpers = {};
      f.contents.toString("utf8").replace(/Handlebars.registerHelper\(('|")([^'"']+?)('|")/g, function(match, p1, p2, p3) {
        helpers[p2] = true;
        return match;
      });
      for (i in DefaultKnownHelpers) {
        HandlebarsOptions.knownHelpers[i] = true;
      }
      for (i in helpers) {
        HandlebarsOptions.knownHelpers[i] = true;
      }
      if (GLOBAL.gulpConfig.verbose) {
        console.log("[Updated HandlebarsHelpers]", HandlebarsOptions.knownHelpers);
      }
      return null;
    }));
    pipeline.emit("data", {
      path: "./src/lib/handlebarhelpers.coffee",
      contents: file,
      isNull: function() {
        return false;
      },
      isStream: function() {
        return false;
      }
    });
    HasRead = true;
    return null;
  };

  compile = function(file) {
    var i, idx, ignored, _i, _len;
    ignored = true;
    for (idx = _i = 0, _len = IgnoreSyntax.length; _i < _len; idx = ++_i) {
      i = IgnoreSyntax[idx];
      if (file.contents[idx] !== i) {
        ignored = false;
        break;
      }
    }
    if (ignored) {
      if (this.shouldLog) {
        console.log("[Handlebars Ignored]", file.relative);
      }
      this.emit("data", file);
      return;
    }
    readHelperFile();
    if (path.extname(file.path) === ".partials") {
      compilePartials(file, this.shouldLog);
    } else {
      compileHbs(file, this.shouldLog);
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

  compilePartials = function(file, shouldLog) {
    var content, data, i, idx, n, namespace, namespaces, newData, result, space, _i, _len;
    content = file.contents.toString("utf8").replace(/\r\n/g, "\n");
    content = content.replace(/^\s+|\s+$/, "").replace(/\}\}\s+/g, "}}");
    data = content.split(/<!--\s*\{\{\s*(.*)\s*\}\}\s*-->\n/ig);
    newData = "";
    namespace = {};
    i = 1;
    while (i < data.length) {
      result = tryCompile(data[i + 1], file);
      if (!result) {
        newData = "";
        break;
      }
      newData += "__TEMPLATE__ =" + result + (";\nTEMPLATE." + data[i] + "=Handlebars.template(__TEMPLATE__);\n\n\n");
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
    if (newData && shouldLog) {
      console.log(util.compileTitle(), file.relative);
    }
    newData = "define(['handlebars'], function(Handlebars){ var __TEMPLATE__, TEMPLATE=" + JSON.stringify(namespace) + ";\n\n" + newData + "return TEMPLATE; });";
    file.contents = new Buffer(newData, "utf8");
    file.path = gutil.replaceExtension(file.path, ".js");
    return null;
  };

  compileHbs = function(file, shouldLog) {
    var newData;
    newData = tryCompile(file.contents.toString("utf8"), file);
    if (newData && shouldLog) {
      console.log(util.compileTitle(), file.relative);
    }
    newData = "define(['handlebars'], function(Handlebars){ var TEMPLATE = " + newData + "; return Handlebars.template(TEMPLATE); });";
    file.contents = new Buffer(newData, "utf8");
    file.path = gutil.replaceExtension(file.path, ".js");
    return null;
  };

  compiler = function(shouldLog) {
    var pipe;
    if (shouldLog == null) {
      shouldLog = true;
    }
    pipe = es.through(compile);
    pipe.shouldLog = shouldLog;
    return pipe;
  };

  compiler.reloadConfig = function() {
    HasRead = false;
    HandlebarsOptions.knownHelpers = {};
    return null;
  };

  module.exports = compiler;

}).call(this);
