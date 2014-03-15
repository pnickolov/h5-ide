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
gulp.task("help", function(){
  console.log( "\n ", gutil.colors.bgBlue.white(" gulp         "), "Compile IDE and start a server @127.0.0.1:3000." );
  console.log( "\n ", gutil.colors.bgBlue.white(" gulp watch   "), "Start a server @127.0.0.1:3000." );
  console.log( "\n ", gutil.colors.bgBlue.white(" gulp dev     "), "Compile IDE" );
  console.log( "\n ", gutil.colors.bgBlue.white(" gulp dev_all "), "Compile IDE including src/model and src/service" );

  console.log( "\n ", gutil.colors.bgBlue.white(" gulp release "), "Compile IDE in release mode, and push to remote master" );
  console.log( "\n ", gutil.colors.bgBlue.white(" gulp debug   "), "Almost the same as `gulp release`, except that the code are not minified and are pushed to remote develop" );
  console.log( "\n ", gutil.colors.bgBlue.white(" gulp qa      "), "Almost the same as `gulp debug`, except that instead of pushing code to remote, it starts a server @127.0.0.1:3002" );
  console.log("");
});
