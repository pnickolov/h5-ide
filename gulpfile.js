var gulp    = require('gulp');
var gutil   = require('gulp-util');

var serverTask = require('./util/gulp_tasks/server');
var fileTask   = require('./util/gulp_tasks/file');

gulp.task("default", function(){

  fileTask.compile();          // Compile everything in `dev` mode
  serverTask.create( "3000" ); // Create a static server
  fileTask.watch();            // Watch File Changes

});

// Create a server without compiling
gulp.task("fast", function(){
  serverTask.create( "3000" ); // Create a static server
  fileTask.watch();            // Watch File Changes
});

// Build different version of ide
gulp.task("dev",     function(){ fileTask.compile(); });
gulp.task("debug",   function(){ buildTask.build("debug");   });
gulp.task("release", function(){ buildTask.build("release"); });

// Upgrade 3rd party library
gulp.task("upgrade", function(){ });

// Help
gulp.task("help", function(){ });
