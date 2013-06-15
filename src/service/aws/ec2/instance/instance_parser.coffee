#*************************************************************************************
#* Filename     : instance_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 13:33:47
#* Description  : parser return data of instance
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'instance_vo', 'result_vo', 'constant', 'jquery' ], ( instance_vo, result_vo, constant, $ ) ->


    #///////////////// Parser for RunInstances return  /////////////////
    #private (parser RunInstances return)
    parserRunInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserRunInstancesReturn


    #///////////////// Parser for StartInstances return  /////////////////
    #private (parser StartInstances return)
    parserStartInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserStartInstancesReturn


    #///////////////// Parser for StopInstances return  /////////////////
    #private (parser StopInstances return)
    parserStopInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserStopInstancesReturn


    #///////////////// Parser for RebootInstances return  /////////////////
    #private (parser RebootInstances return)
    parserRebootInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserRebootInstancesReturn


    #///////////////// Parser for TerminateInstances return  /////////////////
    #private (parser TerminateInstances return)
    parserTerminateInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserTerminateInstancesReturn


    #///////////////// Parser for MonitorInstances return  /////////////////
    #private (parser MonitorInstances return)
    parserMonitorInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserMonitorInstancesReturn


    #///////////////// Parser for UnmonitorInstances return  /////////////////
    #private (parser UnmonitorInstances return)
    parserUnmonitorInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserUnmonitorInstancesReturn


    #///////////////// Parser for BundleInstance return  /////////////////
    #private (parser BundleInstance return)
    parserBundleInstanceReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserBundleInstanceReturn


    #///////////////// Parser for CancelBundleTask return  /////////////////
    #private (parser CancelBundleTask return)
    parserCancelBundleTaskReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserCancelBundleTaskReturn


    #///////////////// Parser for ModifyInstanceAttribute return  /////////////////
    #private (parser ModifyInstanceAttribute return)
    parserModifyInstanceAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserModifyInstanceAttributeReturn


    #///////////////// Parser for ResetInstanceAttribute return  /////////////////
    #private (parser ResetInstanceAttribute return)
    parserResetInstanceAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserResetInstanceAttributeReturn


    #///////////////// Parser for ConfirmProductInstance return  /////////////////
    #private (parser ConfirmProductInstance return)
    parserConfirmProductInstanceReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserConfirmProductInstanceReturn


    #///////////////// Parser for DescribeInstances return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeInstancesResult = ( result ) ->
        #resolve instance
        xml = $.parseXML result[1]

        rootNodeName = xml.documentElement.localName

        instance_list = {}

        instance_list.item = []

        reservationSet = ($.xml2json xml).DescribeInstancesResponse.reservationSet

        if not $.isEmptyObject reservationSet

            if reservationSet.item.constructor == Array

                for item in reservationSet.item

                    if item.instancesSet.item.constructor == Array

                        for i in item.instancesSet.item

                            instance_list.item.push i

                    else

                        instance_list.item.push item.instancesSet.item
            else
            
                instance_list.item.push reservationSet.item.instancesSet.item

        instance_list

    #private (parser DescribeInstances return)
    parserDescribeInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeInstancesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeInstancesReturn


    #///////////////// Parser for DescribeInstanceStatus return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeInstanceStatusResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeInstanceStatusResponse.instanceStatusSet

    #private (parser DescribeInstanceStatus return)
    parserDescribeInstanceStatusReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeInstanceStatusResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeInstanceStatusReturn


    #///////////////// Parser for DescribeBundleTasks return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeBundleTasksResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeBundleTasksResponse.bundleInstanceTasksSet

    #private (parser DescribeBundleTasks return)
    parserDescribeBundleTasksReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeBundleTasksResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeBundleTasksReturn


    #///////////////// Parser for DescribeInstanceAttribute return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeInstanceAttributeResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeInstanceAttributeResponse

    #private (parser DescribeInstanceAttribute return)
    parserDescribeInstanceAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeInstanceAttributeResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeInstanceAttributeReturn


    #///////////////// Parser for GetConsoleOutput return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetConsoleOutputResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).GetConsoleOutputResponse

    #private (parser GetConsoleOutput return)
    parserGetConsoleOutputReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveGetConsoleOutputResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserGetConsoleOutputReturn


    #///////////////// Parser for GetPasswordData return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetPasswordDataResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).GetPasswordDataResponse

    #private (parser GetPasswordData return)
    parserGetPasswordDataReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveGetPasswordDataResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserGetPasswordDataReturn


    #############################################################
    #public
    parserRunInstancesReturn                 : parserRunInstancesReturn
    parserStartInstancesReturn               : parserStartInstancesReturn
    parserStopInstancesReturn                : parserStopInstancesReturn
    parserRebootInstancesReturn              : parserRebootInstancesReturn
    parserTerminateInstancesReturn           : parserTerminateInstancesReturn
    parserMonitorInstancesReturn             : parserMonitorInstancesReturn
    parserUnmonitorInstancesReturn           : parserUnmonitorInstancesReturn
    parserBundleInstanceReturn               : parserBundleInstanceReturn
    parserCancelBundleTaskReturn             : parserCancelBundleTaskReturn
    parserModifyInstanceAttributeReturn      : parserModifyInstanceAttributeReturn
    parserResetInstanceAttributeReturn       : parserResetInstanceAttributeReturn
    parserConfirmProductInstanceReturn       : parserConfirmProductInstanceReturn
    parserDescribeInstancesReturn            : parserDescribeInstancesReturn
    parserDescribeInstanceStatusReturn       : parserDescribeInstanceStatusReturn
    parserDescribeBundleTasksReturn          : parserDescribeBundleTasksReturn
    parserDescribeInstanceAttributeReturn    : parserDescribeInstanceAttributeReturn
    parserGetConsoleOutputReturn             : parserGetConsoleOutputReturn
    parserGetPasswordDataReturn              : parserGetPasswordDataReturn
    resolveDescribeInstancesResult           : resolveDescribeInstancesResult
