#*************************************************************************************
#* Filename     : request_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:07
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

    URL = '/request/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "request." + api_name + " callback is null"
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
            console.log "request." + api_name + " error:" + error.toString()


        true
    # end of send_request

    # parse each resource
    parseResource = (resource) ->
        request_vo.resource.userid      = resource["id"]
        request_vo.resource.code        = resource["code"]
        request_vo.resource.submit_time = resource["time_submit"]
        request_vo.resource.begin_time  = resource["time_begin"]
        request_vo.resource.end_time    = resource["time_end"]
        request_vo.resource.brief       = resource["brief"]
        request_vo.resource.data        = resource["data"]

        request_vo.request_info.data.push request_vo.resource

    #///////////////// Parser for init return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInitResult = ( result ) ->
        #resolve result
        request_vo.request_info.time = result[0]
        request_vo.request_info.data = []

        parseResource resource for resource in result[1]

        #return vo
        request_vo.request_info

    #private (parser init return)
    parserInitReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveInitResult result

            forge_result.resolved_data = resolved_data

        #3.return vo
        forge_result

    # end of parserInitReturn


    #///////////////// Parser for update return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveUpdateResult = ( result ) ->
        #resolve result
        request_vo.request_info.time = result[0]
        request_vo.request_info.data = []

        parseResource resource for resource in result[1]

        #return vo
        request_vo.request_info

    #private (parser update return)
    parserUpdateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveUpdateResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserUpdateReturn


    #############################################################

    #def init(self, username, session_id, region_name):
    init = ( src, username, session_id, region_name, callback ) ->
        send_request "init", src, [ username, session_id, region_name ], parserInitReturn, callback
        true

    #def update(self, username, session_id, region_name, timestamp=None):
    update = ( src, username, session_id, region_name, timestamp=null, callback ) ->
        send_request "update", src, [ username, session_id, region_name, timestamp ], parserUpdateReturn, callback
        true


    #############################################################
    #public
    init                         : init
    update                       : update

