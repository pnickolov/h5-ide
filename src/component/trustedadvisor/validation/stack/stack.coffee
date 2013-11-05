define [ 'constant', 'jquery', 'MC','i18n!nls/lang.js', 'stack_service' , '../result_vo' ], ( constant, $, MC, lang, stackService ) ->

	_getCompName = (compUID) ->

		compName = ''
		compObj = MC.canvas_data.component[compUID]
		if compObj and compObj.name
			compName = compObj.name
		return compName

	verify = (callback) ->

		try
			if !callback
				callback = () ->

			validData = $.extend true, {}, MC.canvas_data
			stackService.verify {sender: this},
				$.cookie( 'usercode' ),
				$.cookie( 'session_id' ),
				validData, (result) ->

					checkResult = true
					returnInfo = null
					errInfoStr = ''

					if !result.is_error
						validResultObj = result.resolved_data
						if typeof(validResultObj) is 'object'
							if validResultObj.result
								callback(null)
							else
								checkResult = false

								try
									returnInfo = validResultObj.cause
									returnInfoObj = JSON.parse(returnInfo)

									# get api call info
									errCompUID = returnInfoObj.uid
									errMessage = returnInfoObj.message
									errCompName = _getCompName(errCompUID)

									errInfoStr = "Resource #{errCompName} has format problem, #{errMessage}"

								catch err
									errInfoStr = "Stack format validation error"
						else
							callback(null)
					else
						return null

					if checkResult
						callback(null)
					else
						validResultObj = {
							level: constant.TA.ERROR,
							info: errInfoStr
						}
						callback(validResultObj)
						console.log(validResultObj)

			# immediately return
			tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_CHECKING_FORMAT_VALID
			return {
				level: constant.TA.ERROR,
				info: tipInfo
			}
		catch err
			return null

	verify : verify
