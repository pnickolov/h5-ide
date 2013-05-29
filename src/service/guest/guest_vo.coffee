#*************************************************************************************
#* Filename     : guest_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:01
#* Description  : vo define for guest
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    guest_info = {
        id          : null
        state       : null
        name        : null
        owner       : null
        region      : null
        stack_id    : null
        stack_name  : null
        information : null
        property    : null
        request_id  : null
        app_id      : null
        history     : null
    }

    invite_info = {
        request_id      : null
        state           : null
        request_brief   : null
        submit_time     : null
        request_rid     : null
    }

    #public
    guest_info  : guest_info
    invite_info : invite_info

