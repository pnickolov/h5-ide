#*************************************************************************************
#* Filename     : favorite_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:01
#* Description  : vo define for favorite
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    favorite_info = {
        resources       : null
    }

    resource_info = {
        usercode        : null
        region          : null
        provider        : null
        service         : null
        resource_type   : null
        resource_id     : null
        resource        : null
    }

    #public
    favorite_info : favorite_info
    resource_info : resource_info

