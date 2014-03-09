(function() {
  module.exports = {
    mainConfigFile: "./build/js/ide/config.js",
    baseUrl: "./build",
    dir: "./build2",
    optimize: "none" || "uglify",
    skipDirOptimize: true || false,
    optimizeCss: "none" || "standard",
    modules: [
      {
        name: "vender/vender"
      }
    ]
  };

}).call(this);
