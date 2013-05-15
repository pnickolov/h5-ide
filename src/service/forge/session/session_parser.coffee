
define [ 'vo' ], ( VO ) ->

	parserUserVO = ( arr ) ->
		#set vo
		VO.user_vo.userid      = arr[0]
		VO.user_vo.usercode    = arr[1]
		VO.user_vo.session_id  = arr[2]
		VO.user_vo.region_name = arr[3]
		VO.user_vo.email       = arr[4]
		VO.user_vo.has_cred    = arr[5]

		#return vo
		VO.user_vo

	#public
	parserUserVO : parserUserVO