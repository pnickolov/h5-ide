var $, App, Design, browser, stackJsons, window, _;

browser = require('./env/Browser');

_ = require('underscore');

window = browser.window;

$ = window.$;

App = window.App;

Design = window.Design;

stackJsons = require('./stack/requireStacks');

describe("VisualOps Integration Test", function() {
  var appModel, opsModelState, stackJson, stackModel, unwatchAppProcess, watchAppProcess, _i, _len, _results;
  stackModel = null;
  appModel = null;
  opsModelState = null;
  watchAppProcess = function(ops, callback) {
    ops.on('change:progress', function() {
      return console.log("Progress: %" + (ops.get('progress')));
    });
    ops.on('change:state', function() {
      var state;
      state = ops.get('state');
      if (state === opsModelState.RollingBack) {
        throw 'Operation faild and Rrlling back';
        return;
      }
      return callback(state);
    });
    return ops.on('destroy', function() {
      return callback(ops.get('state'));
    });
  };
  unwatchAppProcess = function(ops) {
    ops.off('change:progress');
    ops.off('change:state');
    return ops.off('destroy');
  };
  console.log('------------------------');
  console.log('Integration Testing for Stack', _.pluck(stackJsons, 'name').join(', '));
  console.log('------------------------');
  _results = [];
  for (_i = 0, _len = stackJsons.length; _i < _len; _i++) {
    stackJson = stackJsons[_i];
    it("Import and Save Stack", function(done) {
      console.log('Import and Save Stack Test Start...');
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
      console.log('Run Stack Test Start...');
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
      console.log('Stop App Test Start...');
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
      console.log('Start App Test Start...');
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
      console.log('Terminate App Test Start...');
      watchAppProcess(appModel, function(state) {
        if (state === opsModelState.Destroyed) {
          unwatchAppProcess(appModel);
          return done();
        }
      });
      return appModel.terminate().fail(function() {
        throw new Error(err);
      });
    });
    _results.push(it("Delete Stack", function(done) {
      console.log('Terminate App Test Start...');
      return stackModel.remove().then(function() {
        return done();
      }, function(err) {
        throw new Error(err);
      });
    }));
  }
  return _results;
});
