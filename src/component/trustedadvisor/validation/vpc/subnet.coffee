define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

	isAbleConnectToELB = ( subnet_id, elb_id ) ->
		console.debug subnet_id, elb_id
		subnet = MC.canvas_data.component[ subnet_id ]
		elb = MC.canvas_data.component[ elb_id ]

		cidr = + subnet.resource.CidrBlock.split('/')[1]

		if cidr <= 27
			return null

		tipInfo = sprintf lang.ide.TA_CIDR_ERROR_CONNECT_TO_ELB, subnet.name

		# return
		level: constant.TA.ERROR
		info: tipInfo



	# public
	isAbleConnectToELB : isAbleConnectToELB