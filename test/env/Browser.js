(function() {
  var Browser, zombie;

  zombie = require("zombie");

  Browser = {
    globalBrowser: new zombie({
      silent: true
    })
  };

  module.exports = Browser;

}).call(this);
