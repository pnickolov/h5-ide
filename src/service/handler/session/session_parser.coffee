
define [ 'session_vo', 'result_vo', 'constant' ], ( session_vo, result_vo, constant ) ->

	#private (resolve result to session_info )
	resolveVO = ( result ) ->
		#resolve result
		session_vo.session_info.userid      = result[0]
		session_vo.session_info.usercode    = result[1]
		session_vo.session_info.session_id  = result[2]
		session_vo.session_info.region_name = result[3]
		session_vo.session_info.email       = result[4]
		session_vo.session_info.has_cred    = result[5]

		#return session_info
		session_vo.session_info

	#private (parser login return)
	parseLoginResult = ( result, return_code, param ) ->

		is_error         = true # only E_OK is false
		error_message    = ""
		resolved_data    = null

		try

			switch return_code
				when constant.RETURN_CODE.E_OK
					resolved_data   = resolveVO result
					is_error       = false
				when constant.RETURN_CODE.E_NONE    then error_message = result.toString() #"Invalid username or password"
				when constant.RETURN_CODE.E_INVALID then error_message = result.toString() #"Invalid username or password"
				when constant.RETURN_CODE.E_EXPIRED then error_message = result.toString() #"Your subscription expired"
				when constant.RETURN_CODE.E_UNKNOWN then error_message = constant.MESSAGE_E.E_UNKNOWN #"Invalid username or password"
				else console.log result.toString()

		catch error

			is_error = true;
			console.log error.toString()

		finally

			#orial
			result_vo.forge_result.return_code      = return_code
			result_vo.forge_result.param            = param

			#resolved
			result_vo.forge_result.is_error         = is_error
			result_vo.forge_result.resolved_data    = resolved_data
			result_vo.forge_result.error_message    = error_message

		#return vo
		result_vo.forge_result
	# end of parseLoginResult


	#public
	parseLoginResult : parseLoginResult