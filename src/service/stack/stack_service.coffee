#*************************************************************************************
#* Filename     : stack_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:02
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'stack_parser', 'result_vo' ], ( MC, stack_parser, result_vo ) ->

    URL = '//'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "stack." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    result_vo.forge_result = parser result, return_code, param_ary

                    callback result_vo.forge_result

                error : ( result, return_code ) ->

                    result_vo.forge_result.return_code      = return_code
                    result_vo.forge_result.is_error         = true
                    result_vo.forge_result.error_message    = result.toString()

                    callback result_vo.forge_result
            }

        catch error
            console.log "stack." + method + " error:" + error.toString()


        true
    # end of send_request

    #def create(self, username, session_id, region_name, spec):
    create = ( username, session_id, region_name, spec, callback ) ->
        send_request "create", [ username, session_id, region_name, spec ], stack_parser.parserCreateReturn, callback
        true

    #def remove(self, username, session_id, region_name, stack_id, stack_name=None):
    remove = ( username, session_id, region_name, stack_id, stack_name=null, callback ) ->
        send_request "remove", [ username, session_id, region_name, stack_id, stack_name ], stack_parser.parserRemoveReturn, callback
        true

    #def save(self, username, session_id, region_name, spec):
    save = ( username, session_id, region_name, spec, callback ) ->
        send_request "save", [ username, session_id, region_name, spec ], stack_parser.parserSaveReturn, callback
        true

    #def rename(self, username, session_id, region_name, stack_id, new_name, stack_name=None):
    rename = ( username, session_id, region_name, stack_id, new_name, stack_name=null, callback ) ->
        send_request "rename", [ username, session_id, region_name, stack_id, new_name, stack_name ], stack_parser.parserRenameReturn, callback
        true

    #def run(self, username, session_id, region_name, stack_id, app_name, app_desc=None, app_component=None, app_property=None, app_layout=None, stack_name=None):
    run = ( username, session_id, region_name, stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null, callback ) ->
        send_request "run", [ username, session_id, region_name, stack_id, app_name, app_desc, app_component, app_property, app_layout, stack_name ], stack_parser.parserRunReturn, callback
        true

    #def save_as(self, username, session_id, region_name, stack_id, new_name, stack_name=None):
    save_as = ( username, session_id, region_name, stack_id, new_name, stack_name=null, callback ) ->
        send_request "save_as", [ username, session_id, region_name, stack_id, new_name, stack_name ], stack_parser.parserSaveAsReturn, callback
        true

    #def info(self, username, session_id, region_name, stack_ids=None):
    info = ( username, session_id, region_name, stack_ids=null, callback ) ->
        send_request "info", [ username, session_id, region_name, stack_ids ], stack_parser.parserInfoReturn, callback
        true


    #############################################################
    #public
    create                       : create
    remove                       : remove
    save                         : save
    rename                       : rename
    run                          : run
    save_as                      : save_as
    info                         : info

