#*************************************************************************************
#* Filename     : favorite_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:09
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

    URL = '/favorite/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "favorite." + api_name + " callback is null"
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
            console.log "favorite." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #///////////////// Parser for add return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveAddResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser add return)
    parserAddReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveAddResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserAddReturn


    #///////////////// Parser for remove return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRemoveResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

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


    #///////////////// Parser for info return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInfoResult = ( result ) ->
        favorite_list = []
        #resolve result

        for res in result
            resource_info = {}
            resource_info.usercode      = res['username']
            resource_info.region        = res['region']
            resource_info.provider      = res['provider']
            resource_info.service       = res['service']
            resource_info.resource_type = res['resource']
            resource_info.resource_id   = res['id']
            resource_info.resource_info = res['amiVO']

            favorite_list.push resource_info

        #return vo
        favorite_list

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


    #############################################################

    #def add(self, username, session_id, region_name, resource):
    add = ( src, username, session_id, region_name, resource, callback ) ->
        send_request "add", src, [ username, session_id, region_name, resource ], parserAddReturn, callback
        true

    #def remove(self, username, session_id, region_name, resource_ids):
    remove = ( src, username, session_id, region_name, resource_ids, callback ) ->
        send_request "remove", src, [ username, session_id, region_name, resource_ids ], parserRemoveReturn, callback
        true

    #def info(self, username, session_id, region_name, provider='AWS', service='EC2', resource='AMI'):
    info = ( src, username, session_id, region_name, provider='AWS', service='EC2', resource='AMI', callback ) ->
        send_request "info", src, [ username, session_id, region_name, provider, service, resource ], parserInfoReturn, callback
        true


    #############################################################
    #public
    add                          : add
    remove                       : remove
    info                         : info

