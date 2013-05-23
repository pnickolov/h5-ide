(function() {
  require(['MC', 'jquery', 'session_service', 'instance_service'], function(MC, $, session_service, instance_service) {
    var can_test, password, region_name, session_id, usercode, username;

    username = "xjimmy";
    password = "aaa123aa";
    session_id = "";
    usercode = "";
    region_name = "";
    can_test = false;
    test("Check test user", function() {
      if (username === "" || password === "") {
        return ok(false, "please set the username and password first, then try again");
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
      return session_service.login(username, password, function(forge_result) {
        var session_info;

        if (!forge_result.is_error) {
          session_info = forge_result.resolved_data;
          session_id = session_info.session_id;
          usercode = session_info.usercode;
          region_name = session_info.region_name;
          ok(true, "login succeed" + "( usercode : " + usercode + " , region_name : " + region_name + " , session_id : " + session_id + ")");
          return start();
        } else {
          ok(false, "login failed, error is " + forge_result.error_message + ", cancel the follow-up test!");
          return start();
        }
      });
    });
    module("Module AWS.EC2.Instance");
    return asyncTest("aws.ec2.instance.DescribeInstances", function() {
      console.log("DescribeInstances(" + usercode + "," + session_id + "," + region_name + ")");
      return instance_service.DescribeInstances(usercode, session_id, region_name, null, null, function(aws_result) {
        var instanceList;

        if (!aws_result.is_error) {
          instanceList = aws_result.resolved_data;
          ok(true, "aws.ec2.instance.DescribeInstances() succeed");
          return start();
        } else {
          ok(false, "aws.ec2.instance.DescribeInstances() failed" + aws_result.error_message);
          return start();
        }
      });
    });
  });

}).call(this);
