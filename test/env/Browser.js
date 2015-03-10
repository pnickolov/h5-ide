var Browser, browser;

Browser = require("zombie");

Browser.localhost('ide.xxx.io', 3010);

module.exports = browser = new Browser({
  waitDuration: "30s"
});

browser.on("loading", function(document) {
  var originXHR;
  originXHR = document.window.XMLHttpRequest;
  if (!(new originXHR()).withCredentials) {
    console.log("[Debug] Adding CORS support");
    document.window.XMLHttpRequest = function() {
      var a;
      (a = new originXHR()).withCredentials = true;
      return a;
    };
  }
});
