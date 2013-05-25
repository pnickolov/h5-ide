#*************************************************************************************
#* Filename     : ec2_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:09
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'ec2_parser', 'result_vo' ], ( MC, ec2_parser, result_vo ) ->

    URL = '/aws/ec2/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "ec2." + api_name + " callback is null"
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
            console.log "ec2." + method + " error:" + error.toString()


        true
    # end of send_request

    #def CreateTags(self, username, session_id, region_name, resource_ids, tags):
    CreateTags = ( username, session_id, region_name, resource_ids, tags, callback ) ->
        send_request "CreateTags", [ username, session_id, region_name, resource_ids, tags ], ec2_parser.parserCreateTagsReturn, callback
        true

    #def DeleteTags(self, username, session_id, region_name, resource_ids, tags):
    DeleteTags = ( username, session_id, region_name, resource_ids, tags, callback ) ->
        send_request "DeleteTags", [ username, session_id, region_name, resource_ids, tags ], ec2_parser.parserDeleteTagsReturn, callback
        true

    #def DescribeTags(self, username, session_id, region_name, filters=None):
    DescribeTags = ( username, session_id, region_name, filters=null, callback ) ->
        send_request "DescribeTags", [ username, session_id, region_name, filters ], ec2_parser.parserDescribeTagsReturn, callback
        true

    #def DescribeRegions(self, username, session_id, region_names=None, filters=None):
    DescribeRegions = ( username, session_id, region_names=null, filters=null, callback ) ->
        send_request "DescribeRegions", [ username, session_id, region_names, filters ], ec2_parser.parserDescribeRegionsReturn, callback
        true

    #def DescribeAvailabilityZones(self, username, session_id, region_name, zone_names=None, filters=None):
    DescribeAvailabilityZones = ( username, session_id, region_name, zone_names=null, filters=null, callback ) ->
        send_request "DescribeAvailabilityZones", [ username, session_id, region_name, zone_names, filters ], ec2_parser.parserDescribeAvailabilityZonesReturn, callback
        true


    #############################################################
    #public
    CreateTags                   : CreateTags
    DeleteTags                   : DeleteTags
    DescribeTags                 : DescribeTags
    DescribeRegions              : DescribeRegions
    DescribeAvailabilityZones    : DescribeAvailabilityZones

