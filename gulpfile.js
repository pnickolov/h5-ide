var gulp  = require('gulp');
var gutil = require('gulp-util');
var fs    = require('fs');

var serverTask  = require('./util/gulp_tasks/server');
var buildTask   = require('./util/gulp_tasks/build');

// Load user-config
if ( fs.existsSync("./gulpconfig.js") )
  GLOBAL.gulpConfig = require('./gulpconfig');
else
  GLOBAL.gulpConfig = require('./gulpconfig-default');


gulp.task("default", ["dev"], function(){
  serverTask.create(); // Create a static server
  buildTask.watch();   // Watch File Changes
});

// Create a server without compiling
gulp.task("watch", function(){
  serverTask.create(); // Create a static server
  buildTask.watch();   // Watch File Changes
});

// Build different version of ide
gulp.task("dev",     function(){ return buildTask.compileDev(); });
gulp.task("dev_all", function(){ return buildTask.compileDev( true ); });
gulp.task("debug",   function(){ buildTask.build("debug");   });
gulp.task("release", function(){ buildTask.build("release"); });

// Upgrade 3rd party library
gulp.task("upgrade", function(){ });

// Help
gulp.task("help", function(){ });
