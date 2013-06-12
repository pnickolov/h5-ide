#*************************************************************************************
#* Filename     : acl_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:24
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'acl_parser', 'result_vo' ], ( MC, acl_parser, result_vo ) ->

    URL = '/aws/vpc/acl/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "acl." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, src
                    aws_result = {}
                    aws_result = parser result, return_code, param_ary

                    callback aws_result

                error : ( result, return_code ) ->

                    aws_result = {}
                    aws_result.return_code      = return_code
                    aws_result.is_error         = true
                    aws_result.error_message    = result.toString()

                    callback aws_result
            }

        catch error
            console.log "acl." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeNetworkAcls(self, username, session_id, region_name, acl_ids=None, filters=None):
    DescribeNetworkAcls = ( src, username, session_id, region_name, acl_ids=null, filters=null, callback ) ->
        send_request "DescribeNetworkAcls", src, [ username, session_id, region_name, acl_ids, filters ], acl_parser.parserDescribeNetworkAclsReturn, callback
        true


    #############################################################
    #public
    DescribeNetworkAcls          : DescribeNetworkAcls

