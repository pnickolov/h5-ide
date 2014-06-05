#############################
#  main for ide
#############################

define [ 'MC', 'constant', 'common_handle', 'validation', 'aws_handle' ], ( MC, constant, common_handle, validation ) ->

	initialize : () ->

		#############################
		#  initialize MC.data
		#############################

		#set MC.data
		#MC.data = {}

		# set default 'dashboard'
		MC.data.current_tab_id = 'dashboard'

		#global config data by region
		MC.data.config = {}
		MC.data.config[r] = {} for r in constant.REGION_KEYS

		#global cache for all ami
		MC.data.dict_ami = {}

		#global stack name list
		MC.data.stack_list = {}
		MC.data.stack_list[r] = [] for r in constant.REGION_KEYS
		#global app name list
		MC.data.app_list = {}
		MC.data.app_list[r] = [] for r in constant.REGION_KEYS

		#
		MC.data.nav_new_stack_list = {}
		MC.data.nav_app_list       = {}
		MC.data.nav_stack_list     = {}

		#global resource data (Describe* return)
		MC.data.resource_list = {}
		MC.data.resource_list[r] = {} for r in constant.REGION_KEYS

		#set untitled
		MC.data.untitled = 0
		#set tab
		MC.tab          = {}
		#set process tab
		MC.process      = {}
		MC.data.process = {}
		MC.storage.remove 'process'

		#save <div class="loading-wrapper" class="main-content active">
		MC.data.loading_wrapper_html = null
		MC.data.is_loading_complete = false

		#save resouce service name
		MC.data.resouceapi = []

		MC.data.account_attribute = {}
		MC.data.account_attribute[r] = { 'support_platform':'', 'default_vpc':'', 'default_subnet':{} } for r in constant.REGION_KEYS

		#
		MC.data.demo_stack_list = constant.DEMO_STACK_NAME_LIST
		#
		MC.open_failed_list = {}

		#trusted advisor
		MC.ta            = {}
		MC.ta            = validation
		MC.ta.list       = []
		MC.ta.state_list = {}

		#state editor
		MC.data.state = {}

		# State clipboard
		MC.data.stateClipboard = []

		#temp
		MC.data.running_app_list = {}

		# include 'NEW_STACK' 'OPEN_STACK' 'OPEN_APP'
		MC.data.open_tab_data    = {}



		return




		#############################
		#  listen ide_event
		#############################
		ide_event.onLongListen ide_event.HIDE_STATUS_BAR,     () -> view.hideStatubar()

		#############################
		#  base model
		#############################

		base_model.sub ( error ) ->
			console.log 'sub'
			if error.return_code is constant.RETURN_CODE.E_SESSION
				# LEGACY code
				App.acquireSession()

				if error.param[0].method is 'info'
					if error.param[0].url in [ '/stack/', '/app/' ]
						ide_event.trigger ide_event.CLOSE_DESIGN_TAB, error.param[4][0]
			else

				label = 'ERROR_CODE_' + error.return_code + '_MESSAGE'
				console.warn lang.service[ label ],error

				return if error.error_message.indexOf( 'AWS was not able to validate the provided access credentials' ) isnt -1
				return if error.param[0].url is '/session/' and error.param[0].method is 'login'

				if error.return_code == -1 and error.error_message == "200"
					if error.param[0].url is '/aws/' and error.param[0].method is 'resource'
						notification 'warning', lang.service["ERROR_CODE_-1_MESSAGE_AWS_RESOURCE"]
					else
						notification 'warning', lang.service[label]
					return null

				if lang.service[ label ]
					error_msg = lang.service[ label ] + "(" + error.return_code + ")"
				else
					error_msg = "unknown error (" + error.return_code + ")"

				if error_msg and $(".error_item").text().indexOf(error_msg) is -1
					notification 'error', error_msg, false

			null

		null
