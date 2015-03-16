var $, App, Design, browser, stackJsons, window;

browser = require('./env/Browser');

window = browser.window;

$ = window.$;

App = window.App;

Design = window.Design;

stackJsons = require('./stack/requireStacks');

describe("VisualOps Integration Testing", function() {
  var appModel, opsModelState, stackJson, stackModel, unwatchAppProcess, watchAppProcess, _i, _len, _results;
  stackModel = null;
  appModel = null;
  opsModelState = null;
  watchAppProcess = function(ops, callback) {
    var callTimes, insideCallback;
    callTimes = 0;
    insideCallback = function() {
      if (callTimes === 0) {
        callTimes++;
        return callback.apply(null, arguments);
      }
    };
    ops.on('change:progress', function() {
      return console.log("Progress: %" + (ops.get('progress')));
    });
    ops.on('change:state', function() {
      var state;
      state = ops.get('state');
      if (state === opsModelState.RollingBack) {
        throw 'Operation faild and Rolling back';
        return;
      }
      return insideCallback(state);
    });
    return ops.on('destroy', function() {
      return insideCallback(state);
    });
  };
  unwatchAppProcess = function(ops) {
    ops.off('change:progress');
    ops.off('change:state');
    return ops.off('destroy');
  };
  console.log('------------------------');
  console.log('Integration Testing for Stacks');
  console.log('------------------------');
  _results = [];
  for (_i = 0, _len = stackJsons.length; _i < _len; _i++) {
    stackJson = stackJsons[_i];
    it("Import and Save Stack", function(done) {
      console.log('Import and Save Stack Testing ...');
      stackModel = App.sceneManager.activeScene().project.createStackByJson(stackJson);
      opsModelState = stackModel.constructor.State;
      App.loadUrl(stackModel.url());
      stackModel.on('change:state', function() {
        if (stackModel.id) {
          return done();
        } else {
          throw new Error('Import Stack Failed');
        }
      });
    });
    it("Run Stack", function(done) {
      var json;
      console.log('Run Stack Testing');
      json = stackModel.getJsonData();
      json.usage = 'testing';
      json.name = stackModel.get('name');
      return stackModel.run(json, json.name).then(function(ops) {
        appModel = ops;
        App.loadUrl(ops.url());
        return watchAppProcess(ops, function(state) {
          if (state === opsModelState.Running) {
            unwatchAppProcess(ops);
            return done();
          }
        });
      }, function(err) {
        throw new Error(err);
      });
    });
    it("Stop App", function(done) {
      console.log('Stop App Testing');
      watchAppProcess(appModel, function(state) {
        if (state === opsModelState.Stopped) {
          unwatchAppProcess(appModel);
          return done();
        }
      });
      return appModel.stop().fail(function() {
        throw new Error(err);
      });
    });
    it("Start App", function(done) {
      console.log('Start App Testing');
      watchAppProcess(appModel, function(state) {
        if (state === opsModelState.Running) {
          unwatchAppProcess(appModel);
          return done();
        }
      });
      return appModel.start().fail(function() {
        throw new Error(err);
      });
    });
    it("Terminate App", function(done) {
      console.log('Terminate App Testing');
      watchAppProcess(appModel, function(state) {
        if (state === opsModelState.Terminating) {
          unwatchAppProcess(appModel);
          return done();
        }
      });
      return appModel.terminate().fail(function() {
        throw new Error(err);
      });
    });
    _results.push(it("Delete Stack", function(done) {
      console.log('Delete Stack Testing');
      return stackModel.remove().then(function() {
        return done();
      }, function(err) {
        throw new Error(err);
      });
    }));
  }
  return _results;
});
