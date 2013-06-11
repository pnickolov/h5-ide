#*************************************************************************************
#* Filename     : placementgroup_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:19
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'placementgroup_parser', 'result_vo' ], ( MC, placementgroup_parser, result_vo ) ->

    URL = '/aws/ec2/placementgroup/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "placementgroup." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, src
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "placementgroup." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def CreatePlacementGroup(self, username, session_id, region_name, group_name, strategy='cluster'):
    CreatePlacementGroup = ( src, username, session_id, region_name, group_name, strategy='cluster', callback ) ->
        send_request "CreatePlacementGroup", src, [ username, session_id, region_name, group_name, strategy ], placementgroup_parser.parserCreatePlacementGroupReturn, callback
        true

    #def DeletePlacementGroup(self, username, session_id, region_name, group_name):
    DeletePlacementGroup = ( src, username, session_id, region_name, group_name, callback ) ->
        send_request "DeletePlacementGroup", src, [ username, session_id, region_name, group_name ], placementgroup_parser.parserDeletePlacementGroupReturn, callback
        true

    #def DescribePlacementGroups(self, username, session_id, region_name, group_names=None, filters=None):
    DescribePlacementGroups = ( src, username, session_id, region_name, group_names=null, filters=null, callback ) ->
        send_request "DescribePlacementGroups", src, [ username, session_id, region_name, group_names, filters ], placementgroup_parser.parserDescribePlacementGroupsReturn, callback
        true


    #############################################################
    #public
    CreatePlacementGroup         : CreatePlacementGroup
    DeletePlacementGroup         : DeletePlacementGroup
    DescribePlacementGroups      : DescribePlacementGroups

