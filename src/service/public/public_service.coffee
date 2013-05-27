#*************************************************************************************
#* Filename     : public_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:58
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'public_parser', 'result_vo' ], ( MC, public_parser, result_vo ) ->

    URL = '/public/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

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
                    result_vo.forge_result = parser result, return_code, param_ary

                    callback result_vo.forge_result

                error : ( result, return_code ) ->

                    result_vo.forge_result.return_code      = return_code
                    result_vo.forge_result.is_error         = true
                    result_vo.forge_result.error_message    = result.toString()

                    callback result_vo.forge_result
            }

        catch error
            console.log "public." + method + " error:" + error.toString()


        true
    # end of send_request

    #def get_hostname(self, region_name, instance_id):
    get_hostname = ( region_name, instance_id, callback ) ->
        send_request "get_hostname", [ region_name, instance_id ], public_parser.parserGetHostnameReturn, callback
        true

    #def get_dns_ip(self, region_name):
    get_dns_ip = ( region_name, callback ) ->
        send_request "get_dns_ip", [ region_name ], public_parser.parserGetDnsIpReturn, callback
        true


    #############################################################
    #public
    get_hostname                 : get_hostname
    get_dns_ip                   : get_dns_ip

