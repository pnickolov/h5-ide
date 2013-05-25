#*************************************************************************************
#* Filename     : subnetgroup_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:21
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'subnetgroup_parser', 'result_vo' ], ( MC, subnetgroup_parser, result_vo ) ->

    URL = '/aws/rds/subnetgroup/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "subnetgroup." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "subnetgroup." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeDBSubnetGroups(self, username, session_id, region_name, sg_name=None, marker=None, max_records=None):
    DescribeDBSubnetGroups = ( username, session_id, region_name, sg_name=null, marker=null, max_records=null, callback ) ->
        send_request "DescribeDBSubnetGroups", [ username, session_id, region_name, sg_name, marker, max_records ], subnetgroup_parser.parserDescribeDBSubnetGroupsReturn, callback
        true


    #############################################################
    #public
    DescribeDBSubnetGroups       : DescribeDBSubnetGroups

