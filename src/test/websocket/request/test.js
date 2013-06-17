(function() {
  require(['WS', 'session_service'], function(WS, session_service) {
    var can_test, password, region_name, session_id, test_websocket, usercode, username;
    username = 'ken';
    password = 'aaa123aa';
    session_id = "";
    usercode = "";
    region_name = "";
    can_test = false;
    test("Check test user", function() {
      if (username === "" || password === "") {
        return ok(false, "please set the username and password first(/test/service/test_util), then try again");
      } else {
        ok(true, "passwd");
        return can_test = true;
      }
    });
    if (!can_test) {
      return false;
    }
    module("Module Session");
    asyncTest("session.login", function() {
      return session_service.login({
        sender: this
      }, username, password, function(forge_result) {
        var session_info;
        if (!forge_result.is_error) {
          session_info = forge_result.resolved_data;
          session_id = session_info.session_id;
          usercode = session_info.usercode;
          region_name = session_info.region_name;
          ok(true, "login succeed" + "( usercode : " + usercode + " , region_name : " + region_name + " , session_id : " + session_id + ")");
          username = usercode;
          return start();
        } else {
          ok(false, "login failed, error is " + forge_result.error_message + ", cancel the follow-up test!");
          return start();
        }
      });
    });
    test_websocket = function() {
      return asyncTest("/websocket", function() {
        var call, error, subscirbed;
        WS.websocketInit();
        subscirbed = new WS.WebSocket();
        try {
          return subscirbed.sub("request", usercode, session_id, region_name, call = function() {
            ok(true, "websocket.sub() succeed");
            console.log('Subscription success');
            return start();
          });
        } catch (_error) {
          error = _error;
          ok(false, "websocket.sub() failed" + error);
          return start();
        }
      });
    };
    return test_websocket();
  });

}).call(this);
