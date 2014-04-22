
require [ 'testsuite', 'constant', 'base_model', 'UI.notification' ], ( testsuite, constant, base_model ) ->

	base_model.sub ( result ) ->
		console.log 'sub'
		if result.return_code isnt constant.RETURN_CODE.E_SESSION

			notification 'error', result.error_message+"("+result.return_code+")", false

			service  = $( "#service_list" ).val()
			resource = $( "#resource_list" ).val()
			api      = $( "#api_list" ).val()
			data = window.API_DATA_LIST[ service ][ resource ][ api ]

			$( "#label_request_result" ).text data.method + " failed!"
			$( "#response_data" ).removeClass("prettyprinted").text result.error_message

			response_time = new Date()
			log_data = {
				request_time   : MC.dateFormat(window.request_time, "yyyy-MM-dd hh:mm:ss"),
				response_time  : MC.dateFormat(response_time, "yyyy-MM-dd hh:mm:ss"),
				duration       : (Date.parse(response_time) - Date.parse(window.request_time)) / 1000
				service_name   : service,
				resource_name  : resource,
				api_name       : api,
				json_ok        : "status-red",
				e_ok           : "status-red"
			}

			window.add_request_log log_data

		null

	testsuite.ready()
