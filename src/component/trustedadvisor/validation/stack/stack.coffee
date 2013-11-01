define [ 'constant', 'jquery', 'MC','i18n!nls/lang.js', 'stack_service' , '../result_vo' ], ( constant, $, MC, lang, stackService ) ->

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

					if !result.is_error
						validResultObj = result.resolved_data
						if typeof(validResultObj) is 'object'
							if validResultObj.result
								callback(null)
							else
								checkResult = false
								returnInfo = validResultObj.cause
						else
							callback(null)
					else
						return null

					if checkResult
						callback(null)
					else
						validResultObj = {
							level: constant.TA.ERROR,
							info: returnInfo
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
