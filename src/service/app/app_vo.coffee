#*************************************************************************************
#* Filename     : app_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:59
#* Description  : vo define for app
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    app_request =   {
        "id"                    :   ""
        "state"                 :   ""
        "brief"                 :   ""
        "time_submit"           :   ""
        "rid"                   :   ""
    }

    app_info    =   {
        "version"               :   ""
        "id"                    :   ""
        "stack_id"              :   ""
        "name"                  :   ""
        "owner"                 :   ""
        "description"           :   ""
        "property"              :   {}
        "component"             :   {}
        "layout"                :   ""
        "history"               :   []
        "region"                :   ""
        "state"                 :   ""
        "username"              :   ""
    }
    #public
    app_request :   app_request
    app_info    :   app_info

