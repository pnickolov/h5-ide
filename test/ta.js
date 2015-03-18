var $, App, AsgModel, AzModel, Design, LcModel, MC, OpsModel, SubnetModel, VpcModel, assert, az, browser, design, ops, project, region, subnet, ta, vpc, window;

browser = require('./env/Browser');

window = browser.window;

$ = window.$;

App = window.App;

Design = window.Design;

MC = window.MC;

region = 'us-east-1';

project = App.sceneManager.activeScene().project;

OpsModel = project.stacks().model;

ops = new OpsModel({
  region: region
});

ops.__setJsonData(ops.__defaultJson());

project.stacks().add(ops);

design = new Design(ops);

VpcModel = Design.modelClassForType('AWS.VPC.VPC');

AzModel = Design.modelClassForType('AWS.EC2.AvailabilityZone');

SubnetModel = Design.modelClassForType('AWS.VPC.Subnet');

AsgModel = Design.modelClassForType('AWS.AutoScaling.Group');

LcModel = Design.modelClassForType('AWS.AutoScaling.LaunchConfiguration');

vpc = new VpcModel();

az = new AzModel({
  __parent: vpc
});

subnet = new SubnetModel({
  __parent: az
});

ta = function(compModel) {
  return MC.ta.validAll();
};

assert = function(result, expect) {
  var count, level, levelCount, r, _i, _len;
  levelCount = {
    ERROR: 0,
    WARNING: 0,
    NOTICE: 0
  };
  for (_i = 0, _len = result.length; _i < _len; _i++) {
    r = result[_i];
    levelCount[r.level] += 1;
  }
  for (level in expect) {
    count = expect[level];
    if (count !== levelCount[level]) {
      throw new Error("Expected " + levelCount[level] + " " + level + ", but there is " + levelCount[level]);
    }
  }
  return true;
};

describe("TA", function() {
  console.log('------------------------');
  console.log('TA Testing');
  console.log('------------------------');
  return it("asg.isHasLaunchConfiguration", function() {
    var asg, lc;
    asg = new AsgModel({
      __parent: subnet
    });
    assert(ta(), {
      ERROR: 1
    });
    lc = new LcModel();
    asg.setLc(lc);
    return assert(ta(), {
      ERROR: 0
    });
  });
});
