#*************************************************************************************
#* Filename     : instance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:16
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'instance_parser', 'result_vo' ], ( MC, instance_parser, result_vo ) ->

    URL = '/aws/ec2/instance/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "instance." + api_name + " callback is null"
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
            console.log "instance." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def RunInstances(self, username, session_id, region_name,
    RunInstances = ( src, username, session_id, callback ) ->
        send_request "RunInstances", src, [ username, session_id ], instance_parser.parserRunInstancesReturn, callback
        true

    #def StartInstances(self, username, session_id, region_name, instance_ids=None):
    StartInstances = ( src, username, session_id, region_name, instance_ids=null, callback ) ->
        send_request "StartInstances", src, [ username, session_id, region_name, instance_ids ], instance_parser.parserStartInstancesReturn, callback
        true

    #def StopInstances(self, username, session_id, region_name, instance_ids=None, force=False):
    StopInstances = ( src, username, session_id, region_name, instance_ids=null, force=false, callback ) ->
        send_request "StopInstances", src, [ username, session_id, region_name, instance_ids, force ], instance_parser.parserStopInstancesReturn, callback
        true

    #def RebootInstances(self, username, session_id, region_name, instance_ids=None):
    RebootInstances = ( src, username, session_id, region_name, instance_ids=null, callback ) ->
        send_request "RebootInstances", src, [ username, session_id, region_name, instance_ids ], instance_parser.parserRebootInstancesReturn, callback
        true

    #def TerminateInstances(self, username, session_id, region_name, instance_ids=None):
    TerminateInstances = ( src, username, session_id, region_name, instance_ids=null, callback ) ->
        send_request "TerminateInstances", src, [ username, session_id, region_name, instance_ids ], instance_parser.parserTerminateInstancesReturn, callback
        true

    #def MonitorInstances(self, username, session_id, region_name, instance_ids):
    MonitorInstances = ( src, username, session_id, region_name, instance_ids, callback ) ->
        send_request "MonitorInstances", src, [ username, session_id, region_name, instance_ids ], instance_parser.parserMonitorInstancesReturn, callback
        true

    #def UnmonitorInstances(self, username, session_id, region_name, instance_ids):
    UnmonitorInstances = ( src, username, session_id, region_name, instance_ids, callback ) ->
        send_request "UnmonitorInstances", src, [ username, session_id, region_name, instance_ids ], instance_parser.parserUnmonitorInstancesReturn, callback
        true

    #def BundleInstance(self, username, session_id, region_name, instance_id, s3_bucket, s3_prefix, s3_access_key,
    BundleInstance = ( src, username, session_id, region_name, instance_id, s3_bucket, callback ) ->
        send_request "BundleInstance", src, [ username, session_id, region_name, instance_id, s3_bucket ], instance_parser.parserBundleInstanceReturn, callback
        true

    #def CancelBundleTask(self, username, session_id, region_name, bundle_id):
    CancelBundleTask = ( src, username, session_id, region_name, bundle_id, callback ) ->
        send_request "CancelBundleTask", src, [ username, session_id, region_name, bundle_id ], instance_parser.parserCancelBundleTaskReturn, callback
        true

    #def ModifyInstanceAttribute(self, username, session_id, region_name,
    ModifyInstanceAttribute = ( src, username, session_id, callback ) ->
        send_request "ModifyInstanceAttribute", src, [ username, session_id ], instance_parser.parserModifyInstanceAttributeReturn, callback
        true

    #def ResetInstanceAttribute(self, username, session_id, region_name, instance_id, attribute_name):
    ResetInstanceAttribute = ( src, username, session_id, region_name, instance_id, attribute_name, callback ) ->
        send_request "ResetInstanceAttribute", src, [ username, session_id, region_name, instance_id, attribute_name ], instance_parser.parserResetInstanceAttributeReturn, callback
        true

    #def ConfirmProductInstance(self, username, session_id, region_name, instance_id, product_code):
    ConfirmProductInstance = ( src, username, session_id, region_name, instance_id, product_code, callback ) ->
        send_request "ConfirmProductInstance", src, [ username, session_id, region_name, instance_id, product_code ], instance_parser.parserConfirmProductInstanceReturn, callback
        true

    #def DescribeInstances(self, username, session_id, region_name, instance_ids=None, filters=None):
    DescribeInstances = ( src, username, session_id, region_name, instance_ids=null, filters=null, callback ) ->
        send_request "DescribeInstances", src, [ username, session_id, region_name, instance_ids, filters ], instance_parser.parserDescribeInstancesReturn, callback
        true

    #def DescribeInstanceStatus(self, username, session_id, region_name, instance_ids=None, include_all_instances=False, max_results=1000, next_token=None):
    DescribeInstanceStatus = ( src, username, session_id, region_name, instance_ids=null, include_all_instances=false, max_results=1000, next_token=null, callback ) ->
        send_request "DescribeInstanceStatus", src, [ username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token ], instance_parser.parserDescribeInstanceStatusReturn, callback
        true

    #def DescribeBundleTasks(self, username, session_id, region_name, bundle_ids=None, filters=None):
    DescribeBundleTasks = ( src, username, session_id, region_name, bundle_ids=null, filters=null, callback ) ->
        send_request "DescribeBundleTasks", src, [ username, session_id, region_name, bundle_ids, filters ], instance_parser.parserDescribeBundleTasksReturn, callback
        true

    #def DescribeInstanceAttribute(self, username, session_id, region_name, instance_id, attribute_name):
    DescribeInstanceAttribute = ( src, username, session_id, region_name, instance_id, attribute_name, callback ) ->
        send_request "DescribeInstanceAttribute", src, [ username, session_id, region_name, instance_id, attribute_name ], instance_parser.parserDescribeInstanceAttributeReturn, callback
        true

    #def GetConsoleOutput(self, username, session_id, region_name, instance_id):
    GetConsoleOutput = ( src, username, session_id, region_name, instance_id, callback ) ->
        send_request "GetConsoleOutput", src, [ username, session_id, region_name, instance_id ], instance_parser.parserGetConsoleOutputReturn, callback
        true

    #def GetPasswordData(self, username, session_id, region_name, instance_id, key_data=None):
    GetPasswordData = ( src, username, session_id, region_name, instance_id, key_data=null, callback ) ->
        send_request "GetPasswordData", src, [ username, session_id, region_name, instance_id, key_data ], instance_parser.parserGetPasswordDataReturn, callback
        true


    #############################################################
    #public
    RunInstances                 : RunInstances
    StartInstances               : StartInstances
    StopInstances                : StopInstances
    RebootInstances              : RebootInstances
    TerminateInstances           : TerminateInstances
    MonitorInstances             : MonitorInstances
    UnmonitorInstances           : UnmonitorInstances
    BundleInstance               : BundleInstance
    CancelBundleTask             : CancelBundleTask
    ModifyInstanceAttribute      : ModifyInstanceAttribute
    ResetInstanceAttribute       : ResetInstanceAttribute
    ConfirmProductInstance       : ConfirmProductInstance
    DescribeInstances            : DescribeInstances
    DescribeInstanceStatus       : DescribeInstanceStatus
    DescribeBundleTasks          : DescribeBundleTasks
    DescribeInstanceAttribute    : DescribeInstanceAttribute
    GetConsoleOutput             : GetConsoleOutput
    GetPasswordData              : GetPasswordData

