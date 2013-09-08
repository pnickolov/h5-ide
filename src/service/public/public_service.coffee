#*************************************************************************************
#* Filename     : public_service.coffee
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

    URL = '/public/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "public." + api_name + " callback is null"
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
            console.log "public." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #///////////////// Parser for get_hostname return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetHostnameResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser get_hostname return)
    parserGetHostnameReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveGetHostnameResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserGetHostnameReturn


    #///////////////// Parser for get_dns_ip return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetDnsIpResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser get_dns_ip return)
    parserGetDnsIpReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveGetDnsIpResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserGetDnsIpReturn


    #############################################################

    #def get_hostname(self, region_name, instance_id):
    get_hostname = ( src, region_name, instance_id, callback ) ->
        send_request "get_hostname", src, [ region_name, instance_id ], parserGetHostnameReturn, callback
        true

    #def get_dns_ip(self, region_name):
    get_dns_ip = ( src, region_name, callback ) ->
        send_request "get_dns_ip", src, [ region_name ], parserGetDnsIpReturn, callback
        true


    #############################################################
    #public
    get_hostname                 : get_hostname
    get_dns_ip                   : get_dns_ip

