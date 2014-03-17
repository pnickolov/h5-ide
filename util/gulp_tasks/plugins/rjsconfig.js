(function() {
  var ConfigFile, coffee, es, extend, fs, getConfig, readRequirejsConfig, transformModules, vm;

  fs = require("fs");

  vm = require("vm");

  es = require("event-stream");

  coffee = require("gulp-coffee");

  ConfigFile = "./src/js/ide/config.coffee";

  readRequirejsConfig = function(path) {
    var Context, pipeline, s;
    s = fs.readFileSync(path);
    pipeline = es.through(function() {
      return null;
    });
    pipeline.pipe(coffee()).pipe(es.through(function(f) {
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
      version: "",
      language: "",
      window: {},
      require: function() {},
      document: {
        getElementsByTagName: function() {
          return [];
        },
        cookie: ""
      }
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
    var arg, i, idx, _i, _len;
    for (idx = _i = 0, _len = arguments.length; _i < _len; idx = ++_i) {
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

  transformModules = function(config) {
    var bundleExcludes, bundleName, bundles, exclude, _ref;
    exclude = [];
    config.modules = [];
    bundleExcludes = config.bundleExcludes || {};
    _ref = config.bundles;
    for (bundleName in _ref) {
      bundles = _ref[bundleName];
      config.modules.push({
        name: bundleName,
        include: bundles,
        exclude: exclude.concat(bundleExcludes[bundleName] || [])
      });
      if (exclude.length === 0) {
        exclude.push("i18n!nls/lang.js");
      }
      exclude.push(bundleName);
    }
    delete config.bundles;
    return config;
  };

  getConfig = function(debugMode, outputPath) {
    var config, extra;
    if (debugMode == null) {
      debugMode = true;
    }
    if (outputPath == null) {
      outputPath = "./deploy";
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
    transformModules(config);

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
        include : ["UI.tooltip","UI.scrollbar","UI.tabbar","UI.bubble","UI.modal","UI.table","UI.tablist","UI.selectbox","UI.searchbar","UI.filter","UI.radiobuttons","UI.notification","UI.multiinputbox","UI.canvg","UI.sortable","UI.parsley","UI.errortip"]
        exclude : [ "vender/vender" ]
      }
    ]
     */
    return config;
  };

  module.exports = getConfig;

}).call(this);
