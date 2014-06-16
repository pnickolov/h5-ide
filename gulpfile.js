var gulp  = require('gulp');
var gutil = require('gulp-util');
var fs    = require('fs');
var os    = require('os');

var serverTask  = require('./util/gulp_tasks/server');
var developTask = require('./util/gulp_tasks/develop');
var releaseTask = require('./util/gulp_tasks/release');
var traceTask   = require('./util/gulp_tasks/trace');

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
gulp.task("debug",   function(){ return releaseTask.build( "debug" );   });
gulp.task("release", function(){ return releaseTask.build( "release" ); });

gulp.task("public", function(){ return releaseTask.build( "public" ); });

gulp.task("qa_build", function(){ return releaseTask.build( "qa" ); })
gulp.task("qa", ["qa_build"], function(){ return serverTask.create("./qa", 3002); });

gulp.task("trace", function(){ return traceTask(); });

// Help
gulp.task("help", function(){
  console.log( "\n ===== For Daily Development =====")
  console.log( "\n * gulp          - Compile IDE and start a server @127.0.0.1:3000. Aka `gulp dev;gulp watch`" );
  console.log( "\n * gulp watch    - Start a server @127.0.0.1:3000." );
  console.log( "\n * gulp dev      - Compile IDE, excluding src/model and src/service" );
  console.log( "\n * gulp dev_all  - Compile IDE, including src/model and src/service" );

  console.log( "\n\n ===== For Delpoyment =====")
  console.log( "\n * gulp debug    - Compile IDE in release mode, and push to remote develop" );
  console.log( "\n * gulp release  - Like `gulp debug`, except: minification applied and push to master" );
  console.log( "\n * gulp public   - Like `gulp release`, except: the ide won't redirect to https" );
  console.log( "\n * gulp qa       - Like `gulp debug`, except: serve files @127.0.0.1:3002 instead of pushing code." );
  console.log("");
});
