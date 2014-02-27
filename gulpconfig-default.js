
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

};
