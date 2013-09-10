#*************************************************************************************
#* Filename     : stack_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:10
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

    URL = '/stack/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

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
                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
                    forge_result = {}
                    forge_result = parser result, return_code, param_ary

                    callback forge_result

                error : ( result, return_code ) ->

                    forge_result = {}
                    forge_result.return_code      = return_code
                    forge_result.is_error         = true
                    forge_result.error_message    = result.toString()

                    callback forge_result
            }

        catch error
            console.log "stack." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #///////////////// Parser for create return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveCreateResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser create return)
    parserCreateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveCreateResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserCreateReturn


    #///////////////// Parser for remove return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRemoveResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser remove return)
    parserRemoveReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveRemoveResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserRemoveReturn


    #///////////////// Parser for save return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveSaveResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser save return)
    parserSaveReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveSaveResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserSaveReturn


    #///////////////// Parser for rename return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRenameResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser rename return)
    parserRenameReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveRenameResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserRenameReturn


    #///////////////// Parser for run return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRunResult = ( result ) ->
        stack_run = {}

        #resolve result
        stack_run.id              =   result[0]
        stack_run.state           =   result[1]
        stack_run.brief           =   result[2]
        stack_run.time_submit     =   result[3]
        stack_run.rid             =   result[4]

        #return vo
        stack_run

    #private (parser run return)
    parserRunReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveRunResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserRunReturn


    #///////////////// Parser for save_as return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveSaveAsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser save_as return)
    parserSaveAsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveSaveAsResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserSaveAsReturn


    #///////////////// Parser for info return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInfoResult = ( result ) ->
        #resolve result

        #return vo
        result

    #private (parser info return)
    parserInfoReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveInfoResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserInfoReturn


    #///////////////// Parser for list return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveListResult = ( result ) ->
        #resolve result
        stack_list = {}
        for vo in result
            if stack_list[vo.region] == undefined
                stack_list[vo.region]=[]

            # filter other version
            if vo.version isnt '2013-09-04'
                continue

            stack_list[vo.region].push vo

        #return vo
        stack_list

    #private (parser list return)
    parserListReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveListResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserListReturn


    #############################################################

    #def create(self, username, session_id, region_name, spec):
    create = ( src, username, session_id, region_name, spec, callback ) ->
        send_request "create", src, [ username, session_id, region_name, spec ], parserCreateReturn, callback
        true

    #def remove(self, username, session_id, region_name, stack_id, stack_name=None):
    remove = ( src, username, session_id, region_name, stack_id, stack_name=null, callback ) ->
        send_request "remove", src, [ username, session_id, region_name, stack_id, stack_name ], parserRemoveReturn, callback
        true

    #def save(self, username, session_id, region_name, spec):
    save = ( src, username, session_id, region_name, spec, callback ) ->
        send_request "save", src, [ username, session_id, region_name, spec ], parserSaveReturn, callback
        true

    #def rename(self, username, session_id, region_name, stack_id, new_name, stack_name=None):
    rename = ( src, username, session_id, region_name, stack_id, new_name, stack_name=null, callback ) ->
        send_request "rename", src, [ username, session_id, region_name, stack_id, new_name, stack_name ], parserRenameReturn, callback
        true

    #def run(self, username, session_id, region_name, stack_id, app_name, app_desc=None, app_component=None, app_property=None, app_layout=None, stack_name=None):
    run = ( src, username, session_id, region_name, stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null, callback ) ->
        send_request "run", src, [ username, session_id, region_name, stack_id, app_name, app_desc, app_component, app_property, app_layout, stack_name ], parserRunReturn, callback
        true

    #def save_as(self, username, session_id, region_name, stack_id, new_name, stack_name=None):
    save_as = ( src, username, session_id, region_name, stack_id, new_name, stack_name=null, callback ) ->
        send_request "save_as", src, [ username, session_id, region_name, stack_id, new_name, stack_name ], parserSaveAsReturn, callback
        true

    #def info(self, username, session_id, region_name, stack_ids=None):
    info = ( src, username, session_id, region_name, stack_ids=null, callback ) ->
        send_request "info", src, [ username, session_id, region_name, stack_ids ], parserInfoReturn, callback
        true

    #def list(self, username, session_id, region_name, stack_ids=None):
    list = ( src, username, session_id, region_name, stack_ids=null, callback ) ->
        send_request "list", src, [ username, session_id, region_name, stack_ids ], parserListReturn, callback
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
    list                         : list

