
require [ 'WS', 'session_service'], ( WS, session_service ) ->


	#test user
	username    = 'ken'
	password    = 'aaa123aa'
	#session info
	session_id  = ""
	usercode    = ""
	region_name = ""

	can_test    = false

	test "Check test user", () ->
		if username == "" or password == ""
			ok false, "please set the username and password first(/test/service/test_util), then try again"
		else
			ok true, "passwd"
			can_test = true

	if !can_test
		return false

	#WS.websocketInit()

	################################################
	#session login
	################################################
	module "Module Session"

	asyncTest "session.login", () ->
		session_service.login {sender:this}, username, password, ( forge_result ) ->
			if !forge_result.is_error
			#login succeed
				session_info = forge_result.resolved_data
				session_id   = session_info.session_id
				usercode     = session_info.usercode
				region_name  = session_info.region_name
				ok true, "login succeed" + "( usercode : " + usercode + " , region_name : " + region_name + " , session_id : " + session_id + ")"
				username = usercode
				start()
			else
			#login failed
				ok false, "login failed, error is " + forge_result.error_message + ", cancel the follow-up test!"
				start()

	
	#-----------------------------------------------
	#Test summary()
	#-----------------------------------------------
	test_websocket = () ->
		asyncTest "/websocket", () ->
			WS.websocketInit()
			subscirbed = new WS.WebSocket()
			try
				subscirbed.sub "request", usercode, session_id, region_name, call = () ->

					ok true, "websocket.sub() succeed"

					console.log 'Subscription success'

					start()

			catch error
				ok false, "websocket.sub() failed" + error
				start()

	test_websocket()