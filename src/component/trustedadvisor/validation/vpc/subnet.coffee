define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

	isAbleConnectToELB = ( subnetUid ) ->
		subnet = MC.canvas_data.component[ subnetUid ]
		cidr = + subnet.resource.CidrBlock.split('/')[1]
		console.debug subnet.resource.CidrBlock
		console.debug cidr

		if cidr <= 27
			return null

		tipInfo = sprintf lang.ide.TA_CIDR_ERROR_CONNECT_TO_ELB, subnet.name

		# return
		level: constant.TA.ERROR
		info: tipInfo



	# public
	isAbleConnectToELB : isAbleConnectToELB