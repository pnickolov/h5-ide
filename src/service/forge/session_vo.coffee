
define [], () ->

	#status
	STATUS = {
		E_OK : 0
	}

	#user vo
	user_vo = {
		userid      : ''
		usercode    : ''
		session_id  : ''
		region_name : ''
		email       : ''
		has_cred    : ''
	}

	#public
	STATUS  : STATUS
	user_vo : user_vo