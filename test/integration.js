var $, App, Design, browser, stackjson, window;

browser = require('./env/Browser');

window = browser.window;

$ = window.$;

App = window.App;

Design = window.Design;

stackjson = require('./stack/az-subnet-stack.json');

describe("VisualOps Integration Test", function() {
  var appModel, opsModelState, stackModel, unwatchAppProcess, watchAppProcess;
  stackModel = null;
  appModel = null;
  opsModelState = null;
  watchAppProcess = function(ops, callback) {
    ops.on('change:progress', function() {
      return console.log("Running Process: %" + (ops.get('progress')));
    });
    ops.on('change:state', function() {
      var state;
      state = ops.get('state');
      console.log('watch:', state);
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
    console.log('unwatch');
    ops.off('change:progress');
    ops.off('change:state');
    return ops.off('destroy');
  };
  it("Import and Save Stack", function(done) {
    console.log('Import and Save Stack Test Start...');
    stackModel = App.sceneManager.activeScene().project.createStackByJson(stackjson);
    opsModelState = stackModel.constructor.State;
    App.loadUrl(stackModel.url());
    stackModel.on('change:state', function() {
      console.log('State Changed');
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
      console.log({
        'Stop Log': state
      });
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
      console.log('Start Log: State ', state);
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
  return it("Delete Stack", function(done) {
    console.log('Terminate App Test Start...');
    return stackModel.remove().then(function() {
      return done();
    }, function(err) {
      throw new Error(err);
    });
  });
});
