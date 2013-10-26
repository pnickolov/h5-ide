define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

	isAbleConnectToELB = ( subnetUid ) ->
		if MC.aws.subnet.isAbleConnectToELB subnetUid
			return null

		tipInfo = sprintf lang.ide.TA_CIDR_ERROR_CONNECT_TO_ELB, subnet.name

		# return
		level: constant.TA.ERROR
		info: tipInfo



	# public
	isAbleConnectToELB : isAbleConnectToELB