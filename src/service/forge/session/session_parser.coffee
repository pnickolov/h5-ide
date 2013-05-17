
define [ 'session_vo', 'result_vo', 'constant' ], ( SessionVO, result_vo, constant ) ->

	#private (resolve result to user_vo )
	resolveVO = ( result ) ->
		#resolve result
		SessionVO.user_vo.userid      = result[0]
		SessionVO.user_vo.usercode    = result[1]
		SessionVO.user_vo.session_id  = result[2]
		SessionVO.user_vo.region_name = result[3]
		SessionVO.user_vo.email       = result[4]
		SessionVO.user_vo.has_cred    = result[5]

		#return user_vo
		SessionVO.user_vo

	#private (parser login return)
	parseLoginResult = ( result, return_code, param ) ->

		is_error         = true # only E_OK is false
		resolved_message = ""
		resolved_data    = null

		try

			switch return_code
				when constant.RETURN_CODE.E_OK
					resolved_data   = resolveVO result
					is_error       = false
				when constant.RETURN_CODE.E_NONE    then resolved_message = result.toString() #"Invalid username or password"
				when constant.RETURN_CODE.E_INVALID then resolved_message = result.toString() #"Invalid username or password"
				when constant.RETURN_CODE.E_EXPIRED then resolved_message = result.toString() #"Your subscription expired"
				when constant.RETURN_CODE.E_UNKNOWN then resolved_message = constant.MESSAGE_E.E_UNKNOWN #"Invalid username or password"
				else console.log result.toString()

		catch error

			is_error = true;
			console.log error.toString()

		finally

			#orial
			result_vo.forge_result_vo.return_code      = return_code
			result_vo.forge_result_vo.param            = param

			#resolved
			result_vo.forge_result_vo.is_error         = is_error
			result_vo.forge_result_vo.resolved_data    = resolved_data
			result_vo.forge_result_vo.resolved_message = resolved_message

		#return vo
		result_vo.forge_result_vo
	# end of parseLoginResult


	#public
	parseLoginResult : parseLoginResult