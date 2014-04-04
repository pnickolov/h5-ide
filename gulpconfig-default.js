
// Config that will be used by gulp
module.exports = {

  // The port that will be used by the static file server
  staticFileServerPort : 3000

  // The port that will be used by the livereload server
  , livereloadServerPort : 35729

  // If true, the livereload server will reload the page when js/coffee/html changes.
  , reloadJsHtml : false

  // If true, the compiler will generate coffee source map in the same folder
  , coffeeSourceMap : false

  // If true, the compiler will print additional infomation
  , verbose : false

  // If true, it will use notifier of the system to show error info.
  , enbaleNotifier : true

  // If true, gulp will only compile files that changes content.
  // If false, gulp will compile when a file is saved, even if the content is not modified.
  , enableCache : true

  // If pollingWatch is "auto", it will use native FS in OSX, use polling in other system.
  // If pollingWatch is true, it will force to use polling when watching file changes.
  // If pollingWatch is false, it will force to use native file event
  // Cons of using native file event:
  //   Sometimes changes will not be detected. For example, most of git action.
  // Pros of using native file event:
  //   Fast, CPU-friendly, Won't open too many files at the same time.
  , pollingWatch : "auto"

  // If pollingWatch is false, gulp will use polling to watch .git folder. If there's any change
  // in .git, it will try to recompile the whole project ( enableCache == true can avoid uncessary compile ).
  , gitPollingDebounce : 1000

  // If true, it will automatically open the index of the server.
  , openUrlAfterCreateServer : true

  // Parameters for build
  , buildRepoUrl  : "git@github.com:MadeiraCloud/h5-ide-build.git"
  , buildUsername : "" // If empty, use Global Git Username
  , buildEmail    : "" // If empty, use Global Git Email

  // If true, after running `gulp release` and `gulp debug`, the deploy folder is not removed.
  , keepDeployFolder : true

  // If true, it will try to automatically push the ready-to-depoly build to "git@github.com:MadeiraCloud/h5-ide-build.git"
  , autoPush : true

  // A string to indicate which reporter should mocha use.
  // Possible values are : "dot", "spec", "nyan", "TAP", "List", "progress", "min"
  , testReporter : "nyan"
};
