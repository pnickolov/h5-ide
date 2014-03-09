(function() {
  module.exports = {
    mainConfigFile: "./build/js/ide/config.js",
    baseUrl: "./build",
    dir: "./build2",
    optimize: "none" || "uglify",
    optimizeCss: "none" || "standard",
    skipDirOptimize: true || false,
    removeCombined: true,
    modules: [
      {
        name: "vender/vender",
        create: true,
        include: ["jquery", "backbone", "Meteor"]
      }
    ]
  };

}).call(this);
