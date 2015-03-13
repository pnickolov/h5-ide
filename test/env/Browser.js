var Browser, Q, browser, gutil, logTitle, originWS, originXHR;

Q = require("q");

Browser = require("zombie");

gutil = require("gulp-util");

Browser.localhost('ide.xxx.io', 3010);

module.exports = browser = new Browser({
  waitDuration: "30000s"
});

if (GLOBAL.gulpConfig.showTestRequest || true) {
  browser.on("request", function() {
    return console.log(arguments[0].url);
  });
}

logTitle = function() {
  return "[" + gutil.colors.green("Debug @" + ((new Date()).toLocaleTimeString())) + "]";
};

browser.launchIDE = function() {
  var d;
  d = Q.defer();
  browser.resources.post('http://api.xxx.io/session/', {
    body: '{"jsonrpc":"2.0","id":"1","method":"login","params":["test","aaa123aa",{"timezone":8}]}'
  }, function(error, response) {
    var res;
    if (error) {
      return d.reject(error);
    }
    res = JSON.parse(response.body.toString()).result[1];
    browser.setCookie({
      name: "session_id",
      value: res.session_id,
      maxAge: 3600 * 24 * 30,
      domain: "ide.xxx.io"
    });
    browser.setCookie({
      name: "usercode",
      value: res.username,
      maxAge: 3600 * 24 * 30,
      domain: "ide.xxx.io"
    });
    browser.on("loaded", function() {
      var __inited;
      console.log(logTitle(), "Document loaded.");
      __inited = false;
      return Object.defineProperty(browser.window.constructor.prototype, "__IDE__INITED", {
        configurable: true,
        enumerable: true,
        get: function() {
          return __inited;
        },
        set: function(v) {
          if (!__inited) {
            __inited = v;
            if (v) {
              d.resolve();
            }
          }
        }
      });
    });
    browser.visit("/").then((function() {}), (function(e) {
      if (e) {
        return console.log(e);
      }
    }));
  });
  return d.promise;
};

browser.close = function() {
  var window, ws, xhr, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
  window = browser.window;
  if ((_ref = window.App) != null) {
    if ((_ref1 = _ref.WS) != null) {
      _ref1.close();
    }
  }
  _ref2 = window.____xhrarray || [];
  for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
    xhr = _ref2[_i];
    xhr.abort();
  }
  _ref3 = window.____wsarray || [];
  for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
    ws = _ref3[_j];
    ws.close();
  }
  return Browser.prototype.close.call(this, window);
};

originWS = originXHR = null;

browser.on("loading", function(document) {
  if (!originXHR) {
    originXHR = document.window.XMLHttpRequest;
  }
  if (!originWS) {
    originWS = document.window.WebSocket;
  }
  if (document.window.XMLHttpRequest === originXHR) {
    document.window.XMLHttpRequest = function(a, b, c, d, e) {
      var slice, xhr, xhra;
      xhr = new originXHR(a, b, c, d, e);
      xhr.withCredentials = true;
      xhra = document.window.____xhrarray || (document.window.____xhrarray = []);
      xhra.push(xhr);
      slice = function() {
        xhra.splice(xhra.indexOf(xhr), 1);
        return xhr.removeEventListener("load", slice);
      };
      xhr.addEventListener("load", slice);
      return xhr;
    };
  }
  if (document.window.WebSocket === originWS) {
    document.window.WebSocket = function(a, b, c, d, e) {
      var ws, wsa;
      ws = new originWS(a, b, c, d, e);
      wsa = document.window.____wsarray || (document.window.____wsarray = []);
      wsa.push(ws);
      return ws;
    };
  }
});
