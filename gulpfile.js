var gulp  = require('gulp');
var gutil = require('gulp-util');
var fs    = require('fs');
var os    = require('os');

var serverTask  = require('./util/gulp_tasks/server');
var buildTask   = require('./util/gulp_tasks/build');
var releaseTask = require('./util/gulp_tasks/release');

// Load user-config
GLOBAL.gulpConfig = require('./gulpconfig-default');
if ( fs.existsSync("./gulpconfig.js") ) {
  gutil.log("Loaded Custom Config");
  var custom = require('./gulpconfig')
  for ( var i in custom ) {
    GLOBAL.gulpConfig[ i ] = custom[ i ]
  }
}

if ( GLOBAL.gulpConfig.pollingWatch === "auto" ) {
  if ( os.type() === "Darwin" ) {
    GLOBAL.gulpConfig.pollingWatch = false
  } else {
    GLOBAL.gulpConfig.pollingWatch = true
  }
}

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
gulp.task("debug",   function(){ return releaseTask.build( true );   });
gulp.task("release", function(){ return releaseTask.build(); });

// Upgrade 3rd party library
gulp.task("upgrade", function(){ });

// Help
gulp.task("help", function(){ });
