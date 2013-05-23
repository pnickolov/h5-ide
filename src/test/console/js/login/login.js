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
  define(['MC', 'session_model', 'jquery', 'apiList', 'instance_service'], function(MC, session_model, $, apiList, instance_service) {
    var login, region_name, request, session_id, usercode;

    session_id = "";
    usercode = "";
    region_name = "";
    login = function(event) {
      var password, username;

      event.preventDefault();
      username = $('#login_user').val();
      password = $('#login_password').val();
      session_model.login(username, password);
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
    request = function(event) {
      var current_api, current_resource, current_service, data;

      event.preventDefault();
      current_api = $("#api_list").val();
      if (current_api === null) {
        alert("Please select an api first!");
        return false;
      }
      current_service = $("#service_list").val();
      current_resource = $("#resource_list").val();
      data = window.API_DATA_LIST[current_service][current_resource][current_api];
      return instance_service.DescribeInstances(usercode, session_id, region_name, null, null, function(aws_result) {
        var instanceList;

        if (!aws_result.is_error) {
          instanceList = aws_result.resolved_data;
          $("#label_request_result").text(data.method + " succeed!");
          return $("#response_data").text("aaa");
        } else {
          $("#label_request_result").text(data.method + " failed!");
          return $("#response_data").text(aws_result.error_message);
        }
      });
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
