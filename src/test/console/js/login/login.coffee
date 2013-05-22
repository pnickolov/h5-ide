###

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
###


define [ 'MC', 'session_model' ,'jquery', 'apiList', 'instance_service'], ( MC, session_model, $, apiList, instance_service ) ->
	#session info

	session_id 	= ""
	usercode	= ""
	region_name	= ""


	#private method
	login = ( event ) ->

		event.preventDefault()

		username = $( '#login_user' ).val()
		password = $( '#login_password' ).val()

		#invoke session.login api
		session_model.login username, password

		#login return handler (dispatch from service/session/session_model)
		session_model.once 'SESSION_LOGIN_RETURN', ( forge_result ) ->

			if !forge_result.is_error
			#login succeed

				session_info = forge_result.resolved_data
				session_id   = session_info.session_id
				usercode     = session_info.usercode
				region_name  = session_info.region_name

				$( "#label_login_result" ).text "login succeed, session_id : " + session_info.session_id + ", region_name : " + session_info.region_name

				$('#region_list').val session_info.region_name

				true

			else
			#login failed
				alert forge_result.error_message

				false

		true


	#private
	request = ( event ) ->

		event.preventDefault()

		current_api      = $( "#api_list" ).val()

		if current_api == null
			alert "Please select an api first!"
			return false

		current_service  = $( "#service_list" ).val()
		current_resource = $( "#resource_list" ).val()
		data             = window.API_DATA_LIST[ current_service ][ current_resource ][ current_api ]

		request_time     = new Date()
		response_time    = null


		instance_service.DescribeInstances usercode, session_id, region_name, null, null, ( aws_result ) ->
			if !aws_result.is_error
			#DescribeInstances succeed
				instanceList = aws_result.resolved_data

				$( "#label_request_result" ).text data.method + " succeed!"

				#Object to JSON, pretty print
				$( "#response_data" ).removeClass("prettyprinted").text JSON.stringify(instanceList,null,4  )
				prettyPrint()

				log_data = {
					request_time   : MC.dateFormat(request_time, "yyyy-MM-dd hh:mm:ss"),
					response_time  : MC.dateFormat(new Date(), "yyyy-MM-dd hh:mm:ss"),
					service_name   : current_service,
					resource_name  : current_resource,
					api_name       : current_api,
					json_ok        : "status-green",
					e_ok           : "status-green"
				}

				window.add_request_log log_data

			else
			#DescribeInstances failed

				$( "#label_request_result" ).text data.method + " failed!"
				$( "#response_data" ).text aws_result.error_message


	#public object
	ready : () ->
		$( '#login_form' ).submit( login )
		$( '#request_form' ).submit( request )
		window.init()


