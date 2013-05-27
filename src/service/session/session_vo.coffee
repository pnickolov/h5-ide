#*************************************************************************************
#* Filename     : session_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-27 14:02:51
#* Description  : vo define for session
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #user vo
    session_info = {
        userid      : null
        usercode    : null
        session_id  : null
        region_name : null
        email       : null
        has_cred    : null
    }

    #public
    session_info : session_info