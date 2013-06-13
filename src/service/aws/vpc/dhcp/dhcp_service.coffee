#*************************************************************************************
#* Filename     : dhcp_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:24
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'dhcp_parser', 'result_vo' ], ( MC, dhcp_parser, result_vo ) ->

    URL = '/aws/vpc/dhcp/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "dhcp." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
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
            console.log "dhcp." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeDhcpOptions(self, username, session_id, region_name, dhcp_ids=None, filters=None):
    DescribeDhcpOptions = ( src, username, session_id, region_name, dhcp_ids=null, filters=null, callback ) ->
        send_request "DescribeDhcpOptions", src, [ username, session_id, region_name, dhcp_ids, filters ], dhcp_parser.parserDescribeDhcpOptionsReturn, callback
        true


    #############################################################
    #public
    DescribeDhcpOptions          : DescribeDhcpOptions

