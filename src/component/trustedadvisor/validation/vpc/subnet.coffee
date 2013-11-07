define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

	# isAbleConnectToELB = ( uid ) ->

	# 	# check platform
	# 	if !(MC.canvas_data.platform in
	# 		[MC.canvas.PLATFORM_TYPE.CUSTOM_VPC, MC.canvas.PLATFORM_TYPE.EC2_VPC])
	# 			return null
		
	# 	if MC.aws.subnet.isAbleConnectToELB uid
	# 		return null

	# 	subnet = MC.canvas_data.component[ uid ]
	# 	tipInfo = sprintf lang.ide.TA_MSG_ERROR_CIDR_ERROR_CONNECT_TO_ELB, subnet.name

	# 	# return
	# 	level	: constant.TA.ERROR
	# 	info 	: tipInfo
	# 	uid 	: uid

	# # public
	# isAbleConnectToELB : isAbleConnectToELB

	