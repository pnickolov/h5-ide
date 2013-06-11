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

define [ 'MC', 'favorite_parser', 'result_vo' ], ( MC, favorite_parser, result_vo ) ->

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
                    param_ary.splice 0, 0, src
                    result_vo.forge_result = parser result, return_code, param_ary

                    callback result_vo.forge_result

                error : ( result, return_code ) ->

                    result_vo.forge_result.return_code      = return_code
                    result_vo.forge_result.is_error         = true
                    result_vo.forge_result.error_message    = result.toString()

                    callback result_vo.forge_result
            }

        catch error
            console.log "favorite." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def add(self, username, session_id, region_name, resource):
    add = ( src, username, session_id, region_name, resource, callback ) ->
        send_request "add", src, [ username, session_id, region_name, resource ], favorite_parser.parserAddReturn, callback
        true

    #def remove(self, username, session_id, region_name, resource_ids):
    remove = ( src, username, session_id, region_name, resource_ids, callback ) ->
        send_request "remove", src, [ username, session_id, region_name, resource_ids ], favorite_parser.parserRemoveReturn, callback
        true

    #def info(self, username, session_id, region_name, provider='AWS', service='EC2', resource='AMI'):
    info = ( src, username, session_id, region_name, provider='AWS', service='EC2', resource='AMI', callback ) ->
        send_request "info", src, [ username, session_id, region_name, provider, service, resource ], favorite_parser.parserInfoReturn, callback
        true


    #############################################################
    #public
    add                          : add
    remove                       : remove
    info                         : info

