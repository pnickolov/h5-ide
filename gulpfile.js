var gulp  = require('gulp');
var gutil = require('gulp-util');
var fs    = require('fs');
var os    = require('os');

var serverTask  = require('./util/gulp_tasks/server');
var developTask = require('./util/gulp_tasks/develop');
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
  developTask.watch();   // Watch File Changes
});

// Create a server without compiling
gulp.task("watch", function(){
  serverTask.create(); // Create a static server
  developTask.watch();   // Watch File Changes
});

// Build different version of ide
gulp.task("dev",     function(){ return developTask.compileDev(); });
gulp.task("dev_all", function(){ return developTask.compileDev( true ); });
gulp.task("debug",   function(){ return releaseTask.build( "debug" );   });
gulp.task("release", function(){ return releaseTask.build( "release" ); });

gulp.task("qa_build", function(){ return releaseTask.build( "qa" ); })
gulp.task("qa", ["qa_build"], function(){ return serverTask.create("./qa", 3002); });

// Help
gulp.task("help", function(){ });
