define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

	checkValue = ( uid ) ->

		instanceObj = MC.canvas_data.component[uid]
		instanceName = instanceObj.name
        msg = lang.ide.TA_INSTANCE_NEED_HAVE_A_SUITABLE_EIP instanceName
		resultVO.set resultVO.WARNING, msg, uid

	checkValue : checkValue