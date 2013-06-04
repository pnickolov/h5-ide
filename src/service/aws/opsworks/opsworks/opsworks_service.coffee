#*************************************************************************************
#* Filename     : opsworks_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:20
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'opsworks_parser', 'result_vo' ], ( MC, opsworks_parser, result_vo ) ->

    URL = '/aws/opsworks/opsworks/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "opsworks." + api_name + " callback is null"
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
            console.log "opsworks." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeApps(self, username, session_id, region_name, app_ids=None, stack_id=None):
    DescribeApps = ( src, username, session_id, region_name, app_ids=null, stack_id=null, callback ) ->
        send_request "DescribeApps", src, [ username, session_id, region_name, app_ids, stack_id ], opsworks_parser.parserDescribeAppsReturn, callback
        true

    #def DescribeStacks(self, username, session_id, region_name, stack_ids=None):
    DescribeStacks = ( src, username, session_id, region_name, stack_ids=null, callback ) ->
        send_request "DescribeStacks", src, [ username, session_id, region_name, stack_ids ], opsworks_parser.parserDescribeStacksReturn, callback
        true

    #def DescribeCommands(self, username, session_id, region_name, command_ids=None, deployment_id=None, instance_id=None):
    DescribeCommands = ( src, username, session_id, region_name, command_ids=null, deployment_id=null, instance_id=null, callback ) ->
        send_request "DescribeCommands", src, [ username, session_id, region_name, command_ids, deployment_id, instance_id ], opsworks_parser.parserDescribeCommandsReturn, callback
        true

    #def DescribeDeployments(self, username, session_id, region_name, app_id=None, deployment_ids=None, stack_id=None):
    DescribeDeployments = ( src, username, session_id, region_name, app_id=null, deployment_ids=null, stack_id=null, callback ) ->
        send_request "DescribeDeployments", src, [ username, session_id, region_name, app_id, deployment_ids, stack_id ], opsworks_parser.parserDescribeDeploymentsReturn, callback
        true

    #def DescribeElasticIps(self, username, session_id, region_name, instance_id=None, ips=None):
    DescribeElasticIps = ( src, username, session_id, region_name, instance_id=null, ips=null, callback ) ->
        send_request "DescribeElasticIps", src, [ username, session_id, region_name, instance_id, ips ], opsworks_parser.parserDescribeElasticIpsReturn, callback
        true

    #def DescribeInstances(self, username, session_id, region_name, app_id=None, instance_ids=None, layer_id=None, stack_id=None):
    DescribeInstances = ( src, username, session_id, region_name, app_id=null, instance_ids=null, layer_id=null, stack_id=null, callback ) ->
        send_request "DescribeInstances", src, [ username, session_id, region_name, app_id, instance_ids, layer_id, stack_id ], opsworks_parser.parserDescribeInstancesReturn, callback
        true

    #def DescribeLayers(self, username, session_id, region_name, stack_id, layer_ids=None):
    DescribeLayers = ( src, username, session_id, region_name, stack_id, layer_ids=null, callback ) ->
        send_request "DescribeLayers", src, [ username, session_id, region_name, stack_id, layer_ids ], opsworks_parser.parserDescribeLayersReturn, callback
        true

    #def DescribeLoadBasedAutoScaling(self, username, session_id, region_name, layer_ids):
    DescribeLoadBasedAutoScaling = ( src, username, session_id, region_name, layer_ids, callback ) ->
        send_request "DescribeLoadBasedAutoScaling", src, [ username, session_id, region_name, layer_ids ], opsworks_parser.parserDescribeLoadBasedAutoScalingReturn, callback
        true

    #def DescribePermissions(self, username, session_id, region_name, iam_user_arn, stack_id):
    DescribePermissions = ( src, username, session_id, region_name, iam_user_arn, stack_id, callback ) ->
        send_request "DescribePermissions", src, [ username, session_id, region_name, iam_user_arn, stack_id ], opsworks_parser.parserDescribePermissionsReturn, callback
        true

    #def DescribeRaidArrays(self, username, session_id, region_name, instance_id=None, raid_array_ids=None):
    DescribeRaidArrays = ( src, username, session_id, region_name, instance_id=null, raid_array_ids=null, callback ) ->
        send_request "DescribeRaidArrays", src, [ username, session_id, region_name, instance_id, raid_array_ids ], opsworks_parser.parserDescribeRaidArraysReturn, callback
        true

    #def DescribeServiceErrors(self, username, session_id, region_name, instance_id=None, service_error_ids=None, stack_id=None):
    DescribeServiceErrors = ( src, username, session_id, region_name, instance_id=null, service_error_ids=null, stack_id=null, callback ) ->
        send_request "DescribeServiceErrors", src, [ username, session_id, region_name, instance_id, service_error_ids, stack_id ], opsworks_parser.parserDescribeServiceErrorsReturn, callback
        true

    #def DescribeTimeBasedAutoScaling(self, username, session_id, region_name, instance_ids):
    DescribeTimeBasedAutoScaling = ( src, username, session_id, region_name, instance_ids, callback ) ->
        send_request "DescribeTimeBasedAutoScaling", src, [ username, session_id, region_name, instance_ids ], opsworks_parser.parserDescribeTimeBasedAutoScalingReturn, callback
        true

    #def DescribeUserProfiles(self, username, session_id, region_name, iam_user_arns):
    DescribeUserProfiles = ( src, username, session_id, region_name, iam_user_arns, callback ) ->
        send_request "DescribeUserProfiles", src, [ username, session_id, region_name, iam_user_arns ], opsworks_parser.parserDescribeUserProfilesReturn, callback
        true

    #def DescribeVolumes(self, username, session_id, region_name, instance_id=None, raid_array_id=None, volume_ids=None):
    DescribeVolumes = ( src, username, session_id, region_name, instance_id=null, raid_array_id=null, volume_ids=null, callback ) ->
        send_request "DescribeVolumes", src, [ username, session_id, region_name, instance_id, raid_array_id, volume_ids ], opsworks_parser.parserDescribeVolumesReturn, callback
        true


    #############################################################
    #public
    DescribeApps                 : DescribeApps
    DescribeStacks               : DescribeStacks
    DescribeCommands             : DescribeCommands
    DescribeDeployments          : DescribeDeployments
    DescribeElasticIps           : DescribeElasticIps
    DescribeInstances            : DescribeInstances
    DescribeLayers               : DescribeLayers
    DescribeLoadBasedAutoScaling : DescribeLoadBasedAutoScaling
    DescribePermissions          : DescribePermissions
    DescribeRaidArrays           : DescribeRaidArrays
    DescribeServiceErrors        : DescribeServiceErrors
    DescribeTimeBasedAutoScaling : DescribeTimeBasedAutoScaling
    DescribeUserProfiles         : DescribeUserProfiles
    DescribeVolumes              : DescribeVolumes

