define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

	isAbleConnectToELB = ( uid ) ->
		if MC.aws.subnet.isAbleConnectToELB uid
			return null

		tipInfo = sprintf lang.ide.TA_INFO_ERROR_CIDR_ERROR_CONNECT_TO_ELB, subnet.name

		# return
		level	: constant.TA.ERROR
		info 	: tipInfo
		uid 	: uid



	# public
	isAbleConnectToELB : isAbleConnectToELB