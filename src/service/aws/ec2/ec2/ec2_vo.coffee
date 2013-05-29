#*************************************************************************************
#* Filename     : ec2_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:09
#* Description  : vo define for ec2
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    tag = {
    	'resourceId'				:	''
    	'resourceType'				:	''
    	'key'						:	''
    	'value'						:	''
    }

    region = {
    	'regionName'				:	''
    	'regionEndpoint'			:	''
    }

    zone = {
    	'zoneName'					:	''
    	'zoneState'					:	''
    	'regionName'				:	''
    	'messageSet'				:	''
    }
    #public
    #TO-DO

