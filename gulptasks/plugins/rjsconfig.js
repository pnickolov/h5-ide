var ConfigFile, coffee, es, extend, fs, getConfig, readRequirejsConfig, transformModules, vm;

fs = require("fs");

vm = require("vm");

es = require("event-stream");

coffee = require("gulp-coffee");

ConfigFile = "./src/ide/config.coffee";

readRequirejsConfig = function(path) {
  var Context, pipeline, s;
  s = fs.readFileSync(path);
  pipeline = es.through(function() {
    return null;
  });
  pipeline.pipe(coffee({
    bare: true
  })).pipe(es.through(function(f) {
    s = f.contents.toString("utf8");
    return null;
  }));
  pipeline.emit("data", {
    path: path,
    contents: s,
    isNull: function() {
      return false;
    },
    isStream: function() {
      return false;
    }
  });
  Context = {
    window: false,
    version: "",
    language: "",
    requirejs: {},
    require: function() {}
  };
  Context.require.config = function(config) {
    this.config = config;
    return null;
  };
  Context = vm.createContext(Context);
  vm.runInContext(s, Context);
  return Context.require.config;
};

extend = function(a) {
  var arg, i, idx, j, len;
  for (idx = j = 0, len = arguments.length; j < len; idx = ++j) {
    arg = arguments[idx];
    if (idx === 0) {
      continue;
    }
    for (i in arg) {
      a[i] = arg[i];
    }
  }
  return a;
};

transformModules = function(config, traceMode) {
  var bundleExcludes, bundleName, bundles, exclude, ref;
  exclude = [];
  config.modules = [];
  bundleExcludes = config.bundleExcludes || {};
  ref = config.bundles;
  for (bundleName in ref) {
    bundles = ref[bundleName];
    config.modules.push({
      name: bundleName,
      include: bundles,
      exclude: traceMode ? [] : exclude.concat(bundleExcludes[bundleName] || [])
    });
    if (exclude.length === 0) {
      exclude.push("i18n!/nls/lang.js");
    }
    exclude.push(bundleName);
  }
  delete config.bundles;
  return config;
};

getConfig = function(debugMode, outputPath, traceMode) {
  var config, extra;
  if (debugMode == null) {
    debugMode = true;
  }
  if (outputPath == null) {
    outputPath = "./deploy";
  }
  if (traceMode == null) {
    traceMode = false;
  }
  if (debugMode === true) {
    extra = {
      optimize: "none",
      optimizeCss: "none",
      skipDirOptimize: true
    };
  } else {
    extra = {
      optimizeCss: "standard"
    };
  }
  config = extend(readRequirejsConfig(ConfigFile), extra, {
    removeCombined: true,
    baseUrl: "./build",
    dir: outputPath
  });
  transformModules(config, traceMode);

  /*
   * Example of the modules definination
  config.modules = [
    {
      name    : "vender/vender"
      create  : true
      include : [ "jquery", "underscore", "backbone", "handlebars", "Meteor" ]
    }
  
    {
      name   : "ui/ui"
      create : true
      include : ["UI.tooltip","UI.scrollbar"]
      exclude : [ "vender/vender" ]
    }
  ]
   */
  return config;
};

module.exports = getConfig;
