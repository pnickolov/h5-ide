var window;

window = require("./env/Browser").window;

describe("VisualOps testcase example", function() {
  it("should discover `WS` in App", function() {
    if (!window.App.WS) {
      throw new Error("Cannot find WS in App");
    }
  });
  it("should get response from server", function(done) {
    window.require(["ApiRequest"], function(ApiRequest) {
      return ApiRequest("project_list", {}).then(function(res) {
        return done();
      }, function(err) {
        return done(new Error(err.msg));
      });
    });
  });
});
