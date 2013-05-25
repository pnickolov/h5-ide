#*************************************************************************************
#* Filename     : opsworks_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:16
#* Description  : parser return data of opsworks
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'opsworks_vo', 'result_vo', 'constant' ], ( opsworks_vo, result_vo, constant ) ->


    #///////////////// Parser for DescribeApps return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAppsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeApps return)
    parserDescribeAppsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeAppsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeAppsReturn


    #///////////////// Parser for DescribeStacks return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeStacksResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeStacks return)
    parserDescribeStacksReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeStacksResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeStacksReturn


    #///////////////// Parser for DescribeCommands return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeCommandsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeCommands return)
    parserDescribeCommandsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeCommandsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeCommandsReturn


    #///////////////// Parser for DescribeDeployments return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeDeploymentsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeDeployments return)
    parserDescribeDeploymentsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeDeploymentsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeDeploymentsReturn


    #///////////////// Parser for DescribeElasticIps return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeElasticIpsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeElasticIps return)
    parserDescribeElasticIpsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeElasticIpsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeElasticIpsReturn


    #///////////////// Parser for DescribeInstances return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeInstancesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeInstances return)
    parserDescribeInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeInstancesResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeInstancesReturn


    #///////////////// Parser for DescribeLayers return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeLayersResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeLayers return)
    parserDescribeLayersReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeLayersResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeLayersReturn


    #///////////////// Parser for DescribeLoadBasedAutoScaling return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeLoadBasedAutoScalingResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeLoadBasedAutoScaling return)
    parserDescribeLoadBasedAutoScalingReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeLoadBasedAutoScalingResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeLoadBasedAutoScalingReturn


    #///////////////// Parser for DescribePermissions return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribePermissionsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribePermissions return)
    parserDescribePermissionsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribePermissionsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribePermissionsReturn


    #///////////////// Parser for DescribeRaidArrays return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeRaidArraysResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeRaidArrays return)
    parserDescribeRaidArraysReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeRaidArraysResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeRaidArraysReturn


    #///////////////// Parser for DescribeServiceErrors return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeServiceErrorsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeServiceErrors return)
    parserDescribeServiceErrorsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeServiceErrorsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeServiceErrorsReturn


    #///////////////// Parser for DescribeTimeBasedAutoScaling return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeTimeBasedAutoScalingResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeTimeBasedAutoScaling return)
    parserDescribeTimeBasedAutoScalingReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeTimeBasedAutoScalingResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeTimeBasedAutoScalingReturn


    #///////////////// Parser for DescribeUserProfiles return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeUserProfilesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeUserProfiles return)
    parserDescribeUserProfilesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeUserProfilesResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeUserProfilesReturn


    #///////////////// Parser for DescribeVolumes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeVolumesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeVolumes return)
    parserDescribeVolumesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeVolumesResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeVolumesReturn


    #############################################################
    #public
    parserDescribeAppsReturn                 : parserDescribeAppsReturn
    parserDescribeStacksReturn               : parserDescribeStacksReturn
    parserDescribeCommandsReturn             : parserDescribeCommandsReturn
    parserDescribeDeploymentsReturn          : parserDescribeDeploymentsReturn
    parserDescribeElasticIpsReturn           : parserDescribeElasticIpsReturn
    parserDescribeInstancesReturn            : parserDescribeInstancesReturn
    parserDescribeLayersReturn               : parserDescribeLayersReturn
    parserDescribeLoadBasedAutoScalingReturn : parserDescribeLoadBasedAutoScalingReturn
    parserDescribePermissionsReturn          : parserDescribePermissionsReturn
    parserDescribeRaidArraysReturn           : parserDescribeRaidArraysReturn
    parserDescribeServiceErrorsReturn        : parserDescribeServiceErrorsReturn
    parserDescribeTimeBasedAutoScalingReturn : parserDescribeTimeBasedAutoScalingReturn
    parserDescribeUserProfilesReturn         : parserDescribeUserProfilesReturn
    parserDescribeVolumesReturn              : parserDescribeVolumesReturn

