#*************************************************************************************
#* Filename     : request_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:58
#* Description  : vo define for request
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    request_info = {
    	time	: null
    	data	: null
    }

    resource = {
    	userid		: null
    	code		: null
    	submit_time	: null
    	begin_time	: null
    	end_time	: null
    	brief		: null
    	data		: null
    }

    #public
    request_info : request_info
    resource	 : resource

