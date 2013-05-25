#*************************************************************************************
#* Filename     : instance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 13:33:47
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
    send_request =  ( api_name, param_ary, parser, callback ) ->

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
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "instance." + method + " error:" + error.toString()


        true
    # end of send_request

    #def RunInstances(self, username, session_id, region_name,
    RunInstances = ( username, session_id, callback ) ->
        send_request "RunInstances", [ username, session_id ], instance_parser.parserRunInstancesReturn, callback
        true

    #def StartInstances(self, username, session_id, region_name, instance_ids=None):
    StartInstances = ( username, session_id, region_name, instance_ids=null, callback ) ->
        send_request "StartInstances", [ username, session_id, region_name, instance_ids ], instance_parser.parserStartInstancesReturn, callback
        true

    #def StopInstances(self, username, session_id, region_name, instance_ids=None, force=False):
    StopInstances = ( username, session_id, region_name, instance_ids=null, force=false, callback ) ->
        send_request "StopInstances", [ username, session_id, region_name, instance_ids, force ], instance_parser.parserStopInstancesReturn, callback
        true

    #def RebootInstances(self, username, session_id, region_name, instance_ids=None):
    RebootInstances = ( username, session_id, region_name, instance_ids=null, callback ) ->
        send_request "RebootInstances", [ username, session_id, region_name, instance_ids ], instance_parser.parserRebootInstancesReturn, callback
        true

    #def TerminateInstances(self, username, session_id, region_name, instance_ids=None):
    TerminateInstances = ( username, session_id, region_name, instance_ids=null, callback ) ->
        send_request "TerminateInstances", [ username, session_id, region_name, instance_ids ], instance_parser.parserTerminateInstancesReturn, callback
        true

    #def MonitorInstances(self, username, session_id, region_name, instance_ids):
    MonitorInstances = ( username, session_id, region_name, instance_ids, callback ) ->
        send_request "MonitorInstances", [ username, session_id, region_name, instance_ids ], instance_parser.parserMonitorInstancesReturn, callback
        true

    #def UnmonitorInstances(self, username, session_id, region_name, instance_ids):
    UnmonitorInstances = ( username, session_id, region_name, instance_ids, callback ) ->
        send_request "UnmonitorInstances", [ username, session_id, region_name, instance_ids ], instance_parser.parserUnmonitorInstancesReturn, callback
        true

    #def BundleInstance(self, username, session_id, region_name, instance_id, s3_bucket, s3_prefix, s3_access_key,
    BundleInstance = ( username, session_id, region_name, instance_id, s3_bucket, callback ) ->
        send_request "BundleInstance", [ username, session_id, region_name, instance_id, s3_bucket ], instance_parser.parserBundleInstanceReturn, callback
        true

    #def CancelBundleTask(self, username, session_id, region_name, bundle_id):
    CancelBundleTask = ( username, session_id, region_name, bundle_id, callback ) ->
        send_request "CancelBundleTask", [ username, session_id, region_name, bundle_id ], instance_parser.parserCancelBundleTaskReturn, callback
        true

    #def ModifyInstanceAttribute(self, username, session_id, region_name,
    ModifyInstanceAttribute = ( username, session_id, callback ) ->
        send_request "ModifyInstanceAttribute", [ username, session_id ], instance_parser.parserModifyInstanceAttributeReturn, callback
        true

    #def ResetInstanceAttribute(self, username, session_id, region_name, instance_id, attribute_name):
    ResetInstanceAttribute = ( username, session_id, region_name, instance_id, attribute_name, callback ) ->
        send_request "ResetInstanceAttribute", [ username, session_id, region_name, instance_id, attribute_name ], instance_parser.parserResetInstanceAttributeReturn, callback
        true

    #def ConfirmProductInstance(self, username, session_id, region_name, instance_id, product_code):
    ConfirmProductInstance = ( username, session_id, region_name, instance_id, product_code, callback ) ->
        send_request "ConfirmProductInstance", [ username, session_id, region_name, instance_id, product_code ], instance_parser.parserConfirmProductInstanceReturn, callback
        true

    #def DescribeInstances(self, username, session_id, region_name, instance_ids=None, filters=None):
    DescribeInstances = ( username, session_id, region_name, instance_ids=null, filters=null, callback ) ->
        send_request "DescribeInstances", [ username, session_id, region_name, instance_ids, filters ], instance_parser.parserDescribeInstancesReturn, callback
        true

    #def DescribeInstanceStatus(self, username, session_id, region_name, instance_ids=None, include_all_instances=False, max_results=1000, next_token=None):
    DescribeInstanceStatus = ( username, session_id, region_name, instance_ids=null, include_all_instances=false, max_results=1000, next_token=null, callback ) ->
        send_request "DescribeInstanceStatus", [ username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token ], instance_parser.parserDescribeInstanceStatusReturn, callback
        true

    #def DescribeBundleTasks(self, username, session_id, region_name, bundle_ids=None, filters=None):
    DescribeBundleTasks = ( username, session_id, region_name, bundle_ids=null, filters=null, callback ) ->
        send_request "DescribeBundleTasks", [ username, session_id, region_name, bundle_ids, filters ], instance_parser.parserDescribeBundleTasksReturn, callback
        true

    #def DescribeInstanceAttribute(self, username, session_id, region_name, instance_id, attribute_name):
    DescribeInstanceAttribute = ( username, session_id, region_name, instance_id, attribute_name, callback ) ->
        send_request "DescribeInstanceAttribute", [ username, session_id, region_name, instance_id, attribute_name ], instance_parser.parserDescribeInstanceAttributeReturn, callback
        true

    #def GetConsoleOutput(self, username, session_id, region_name, instance_id):
    GetConsoleOutput = ( username, session_id, region_name, instance_id, callback ) ->
        send_request "GetConsoleOutput", [ username, session_id, region_name, instance_id ], instance_parser.parserGetConsoleOutputReturn, callback
        true

    #def GetPasswordData(self, username, session_id, region_name, instance_id, key_data=None):
    GetPasswordData = ( username, session_id, region_name, instance_id, key_data=null, callback ) ->
        send_request "GetPasswordData", [ username, session_id, region_name, instance_id, key_data ], instance_parser.parserGetPasswordDataReturn, callback
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

