#############################
#  main for ide
#############################

define [ 'MC', 'constant', 'validation', 'aws_handle' ], ( MC, constant, validation ) ->

	initialize : () ->

		#############################
		#  initialize MC.data
		#############################

		#set MC.data
		MC.data = MC.data || {}

		#global config data by region
		MC.data.config = {}
		MC.data.config[r] = {} for r in constant.REGION_KEYS

		#global cache for all ami
		MC.data.dict_ami = {}

		#global stack name list
		MC.data.stack_list = {}
		MC.data.stack_list[r] = [] for r in constant.REGION_KEYS

		#global resource data (Describe* return)
		MC.data.resource_list = {}
		MC.data.resource_list[r] = {} for r in constant.REGION_KEYS

		#trusted advisor
		MC.ta            = {}
		MC.ta            = validation
		MC.ta.list       = []
		MC.ta.state_list = {}

		#state editor
		MC.data.state = {}

		# State clipboard
		MC.data.stateClipboard = []
		return




		#############################
		#  listen ide_event
		#############################
		ide_event.onLongListen ide_event.HIDE_STATUS_BAR,     () -> view.hideStatubar()
