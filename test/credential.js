var $, App, Design, browser, window;

browser = require('./env/Browser');

window = browser.window;

$ = window.$;

App = window.App;

Design = window.Design;

describe("Credential Testing", function() {
  var getCredential, hasApp;
  console.log('------------------------');
  console.log('Credential Testing');
  console.log('------------------------');
  getCredential = function() {
    return App.sceneManager.activeScene().project.credentials().at(0);
  };
  hasApp = function() {
    return !!App.sceneManager.activeScene().project.get('apps').length;
  };
  if (getCredential().isDemo() || hasApp()) {
    return;
  }
  it("Remove Credential", function(done) {
    var credential;
    console.log('Remove Credential Testing ...');
    credential = getCredential();
    credential.destroy().then(function() {
      return done();
    }, function(err) {
      throw err;
    });
  });
  return it("Add Credential", function(done) {
    var credential;
    console.log('Add Credential Testing ...');
    credential = getCredential();
    credential.set({
      alias: 'test',
      awsAccount: 'dev',
      awsAccessKey: 'AKIAJQGLVV6IPLFSKWCQ',
      awsSecretKey: '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'
    });
    credential.save().then(function() {
      return done();
    }, function(err) {
      throw err;
    });
  });
});
