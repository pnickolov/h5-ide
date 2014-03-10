(function() {
  var ConfigFile, DefaultConfig, extend, fs, getConfig, readRequirejsConfig, transformModules, vm;

  fs = require("fs");

  vm = require("vm");

  ConfigFile = "./build/js/ide/config.js";

  DefaultConfig = {
    baseUrl: "./build",
    dir: "./build2",
    removeCombined: true
  };

  readRequirejsConfig = function(path) {
    var Context, source;
    source = fs.readFileSync(path, "utf8");
    Context = {
      require: function() {}
    };
    Context.require.config = function(config) {
      this.config = config;
      return null;
    };
    Context = vm.createContext(Context);
    vm.runInContext(source, Context);
    return Context.require.config;
  };

  extend = function(a, b) {
    var i;
    for (i in b) {
      a[i] = b[i];
    }
    return a;
  };

  transformModules = function(config) {
    var bundleName, bundles, exclude, _ref;
    exclude = [];
    config.modules = [];
    _ref = config.bundles;
    for (bundleName in _ref) {
      bundles = _ref[bundleName];
      if (bundles.length) {
        config.modules.push({
          name: bundleName,
          create: true,
          include: bundles,
          exclude: exclude.length ? exclude : void 0
        });
      }
      exclude = exclude.slice();
      exclude.push(bundleName);
    }
    delete config.bundles;
    return config;
  };

  getConfig = function() {
    var config, debugMode, extra;
    if (debugMode === void 0) {
      debugMode = true;
    }
    if (debugMode) {
      extra = {
        optimize: "none",
        optimizeCss: "none",
        skipDirOptimize: true
      };
    } else {
      extra = {};
    }
    config = extend(extra, DefaultConfig);
    config = extend(readRequirejsConfig(ConfigFile), config);
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
