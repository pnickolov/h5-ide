#*************************************************************************************
#* Filename     : autoscaling_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:03
#* Description  : parser return data of autoscaling
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->


    #///////////////// Parser for DescribeAdjustmentTypes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAdjustmentTypesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeAdjustmentTypes return)
    parserDescribeAdjustmentTypesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeAdjustmentTypesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeAdjustmentTypesReturn


    #///////////////// Parser for DescribeAutoScalingGroups return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAutoScalingGroupsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeAutoScalingGroups return)
    parserDescribeAutoScalingGroupsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeAutoScalingGroupsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeAutoScalingGroupsReturn


    #///////////////// Parser for DescribeAutoScalingInstances return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAutoScalingInstancesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeAutoScalingInstances return)
    parserDescribeAutoScalingInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeAutoScalingInstancesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeAutoScalingInstancesReturn


    #///////////////// Parser for DescribeAutoScalingNotificationTypes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAutoScalingNotificationTypesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeAutoScalingNotificationTypes return)
    parserDescribeAutoScalingNotificationTypesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeAutoScalingNotificationTypesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeAutoScalingNotificationTypesReturn


    #///////////////// Parser for DescribeLaunchConfigurations return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeLaunchConfigurationsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeLaunchConfigurations return)
    parserDescribeLaunchConfigurationsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeLaunchConfigurationsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeLaunchConfigurationsReturn


    #///////////////// Parser for DescribeMetricCollectionTypes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeMetricCollectionTypesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeMetricCollectionTypes return)
    parserDescribeMetricCollectionTypesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeMetricCollectionTypesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeMetricCollectionTypesReturn


    #///////////////// Parser for DescribeNotificationConfigurations return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeNotificationConfigurationsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeNotificationConfigurations return)
    parserDescribeNotificationConfigurationsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeNotificationConfigurationsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeNotificationConfigurationsReturn


    #///////////////// Parser for DescribePolicies return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribePoliciesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribePolicies return)
    parserDescribePoliciesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribePoliciesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribePoliciesReturn


    #///////////////// Parser for DescribeScalingActivities return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeScalingActivitiesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeScalingActivities return)
    parserDescribeScalingActivitiesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeScalingActivitiesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeScalingActivitiesReturn


    #///////////////// Parser for DescribeScalingProcessTypes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeScalingProcessTypesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeScalingProcessTypes return)
    parserDescribeScalingProcessTypesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeScalingProcessTypesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeScalingProcessTypesReturn


    #///////////////// Parser for DescribeScheduledActions return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeScheduledActionsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeScheduledActions return)
    parserDescribeScheduledActionsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeScheduledActionsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeScheduledActionsReturn


    #///////////////// Parser for DescribeTags return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeTagsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeTags return)
    parserDescribeTagsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeTagsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeTagsReturn


    #############################################################
    #public
    parserDescribeAdjustmentTypesReturn      : parserDescribeAdjustmentTypesReturn
    parserDescribeAutoScalingGroupsReturn    : parserDescribeAutoScalingGroupsReturn
    parserDescribeAutoScalingInstancesReturn : parserDescribeAutoScalingInstancesReturn
    parserDescribeAutoScalingNotificationTypesReturn : parserDescribeAutoScalingNotificationTypesReturn
    parserDescribeLaunchConfigurationsReturn : parserDescribeLaunchConfigurationsReturn
    parserDescribeMetricCollectionTypesReturn : parserDescribeMetricCollectionTypesReturn
    parserDescribeNotificationConfigurationsReturn : parserDescribeNotificationConfigurationsReturn
    parserDescribePoliciesReturn             : parserDescribePoliciesReturn
    parserDescribeScalingActivitiesReturn    : parserDescribeScalingActivitiesReturn
    parserDescribeScalingProcessTypesReturn  : parserDescribeScalingProcessTypesReturn
    parserDescribeScheduledActionsReturn     : parserDescribeScheduledActionsReturn
    parserDescribeTagsReturn                 : parserDescribeTagsReturn

