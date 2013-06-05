#*************************************************************************************
#* Filename     : stack_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:02
#* Description  : vo define for stack
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

	#vo declaration
	#TO-DO
	stack_info 	= 	{
		"version"				:	""
		"id"					:	""
		"name"					:	""
		"owner"					:	""
		"description"			:	""
		"property"				:	{}
		"component"				:	{}
		"layout"				:	""
		"history"				:	[]
		"region"				:	""
		"state"					:	""
		"username"				:	""
	}

	stack_run	= 	{
		"id"					: 	""
		"state"					: 	""
		"brief" 				: 	""
		"time_submit"			: 	""
		"rid"					: 	""
	}

	stack_list = []

	#public
	stack_info 	: 	stack_info
	stack_run 	: 	stack_run
	stack_list  :   stack_list

