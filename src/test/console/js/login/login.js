/*

define([ 'MC','jquery' ], function( MC, $ ) {

	MC.login = function ( event )
	{
		event.preventDefault();

		MC.api({
			url: '/session/',
			method: 'login',
			data: [
				$('#login_user').val(),
				$('#login_password').val()
			],
			success: function(data, status)
			{
				if (status === 0)
				{
					$.cookie('user_name', data[1], { expires: 3600 });
					$.cookie('session_id', data[2], { expires: 3600 });

					location = 'map.html';
				}
				else
				{
					alert(data);
					$('#login_form')[0].reset();
				}
			}
		});

		return false;
	};

	return {
		ready : function () {
			$('#login_form').submit(MC.login);
		}
	};

});
*/


(function() {
  define(['MC', 'session_model', 'jquery', 'apiList', 'instance_model'], function(MC, session_model, $, apiList, instance_model) {
    var dict_request, login, me, region_name, request, resolveResult, session_id, usercode;

    session_id = "";
    usercode = "";
    region_name = "";
    dict_request = {};
    me = this;
    login = function(event) {
      var password, username;

      event.preventDefault();
      username = $('#login_user').val();
      password = $('#login_password').val();
      session_model.login({
        sender: this
      }, username, password);
      session_model.once('SESSION_LOGIN_RETURN', function(forge_result) {
        var session_info;

        if (!forge_result.is_error) {
          session_info = forge_result.resolved_data;
          session_id = session_info.session_id;
          usercode = session_info.usercode;
          region_name = session_info.region_name;
          $("#label_login_result").text("login succeed, session_id : " + session_info.session_id + ", region_name : " + session_info.region_name);
          $('#region_list').val(session_info.region_name);
          return true;
        } else {
          alert(forge_result.error_message);
          return false;
        }
      });
      return true;
    };
    resolveResult = function(request_time, service, resource, api, result) {
      var data, log_data;

      data = window.API_DATA_LIST[service][resource][api];
      if (!result.is_error) {
        $("#label_request_result").text(data.method + " succeed!");
        $("#response_data").removeClass("prettyprinted").text(JSON.stringify(result.resolved_data, null, 4));
        prettyPrint();
        log_data = {
          request_time: MC.dateFormat(request_time, "yyyy-MM-dd hh:mm:ss"),
          response_time: MC.dateFormat(new Date(), "yyyy-MM-dd hh:mm:ss"),
          service_name: service,
          resource_name: resource,
          api_name: api,
          json_ok: "status-green",
          e_ok: "status-green"
        };
        return window.add_request_log(log_data);
      } else {
        $("#label_request_result").text(data.method + " failed!");
        return $("#response_data").text(aws_result.error_message);
      }
    };
    request = function(event) {
      var current_api, current_resource, current_service, key, request_time, response_time;

      event.preventDefault();
      current_api = $("#api_list").val();
      if (current_api === null) {
        alert("Please select an api first!");
        return false;
      }
      current_service = $("#service_list").val();
      current_resource = $("#resource_list").val();
      request_time = new Date();
      response_time = null;
      key = current_service + "-" + current_resource + "-" + current_api;
      dict_request[key] = event;
      instance_model.DescribeInstances({
        sender: me
      }, usercode, session_id, region_name, null, null);
      instance_model.once("EC2_INS_DESC_INSTANCES_RETURN", function(aws_result) {
        return resolveResult(request_time, current_service, current_resource, current_api, aws_result);
      });
      return null;
    };
    return {
      ready: function() {
        $('#login_form').submit(login);
        $('#request_form').submit(request);
        return window.init();
      }
    };
  });

}).call(this);
