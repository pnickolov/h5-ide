(function() {
  var testModules;

  QUnit.config.autostart = false;

  testModules = ["/test/service/aws/ec2/instance.js"];

  require(testModules, QUnit.load);

}).call(this);
