#*************************************************************************************
#* Filename     : request_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:58
#* Description  : parser return data of request
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'request_vo', 'result_vo', 'constant' ], ( request_vo, result_vo, constant ) ->

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
    #public
    parserInitReturn                         : parserInitReturn
    parserUpdateReturn                       : parserUpdateReturn

