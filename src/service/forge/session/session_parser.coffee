
define [ 'vo' ], ( vo ) ->

	parser_user_vo = ( arr ) ->
		vo.user_vo.userid      = arr[0]
		vo.user_vo.usercode    = arr[1]
		vo.user_vo.session_id  = arr[2]
		vo.user_vo.region_name = arr[3]
		vo.user_vo.email       = arr[4]
		vo.user_vo.has_cred    = arr[5]
		vo.user_vo

	#public
	parser_user_vo : parser_user_vo