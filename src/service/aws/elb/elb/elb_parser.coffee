#*************************************************************************************
#* Filename     : elb_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:15
#* Description  : parser return data of elb
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->

    resolvedObjectToArray = ( objs ) ->

        if objs.constructor == Array

            for obj in objs

                obj = resolvedObjectToArray obj

        if objs.constructor == Object

            if $.isEmptyObject objs

                objs = null

            for key, value of objs

                if key == 'item' and value.constructor == Object

                    tmp = []

                    tmp.push resolvedObjectToArray value

                    objs[key] = tmp

                else if value.constructor == Object or value.constructor == Array

                    objs[key] = resolvedObjectToArray value

        objs

    #///////////////// Parser for DescribeInstanceHealth return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeInstanceHealthResult = ( result ) ->
        #resolve result
        #return vo
        result_set = ($.xml2json ($.parseXML result[1])).DescribeInstanceHealthResponse.DescribeInstanceHealthResult.InstanceStates.member

        result_set = resolvedObjectToArray result_set

        if result_set.constructor == Object

            tmp = []

            tmp.push result_set

            result_set = tmp

        result_set

    #private (parser DescribeInstanceHealth return)
    parserDescribeInstanceHealthReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeInstanceHealthResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeInstanceHealthReturn


    #///////////////// Parser for DescribeLoadBalancerPolicies return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeLoadBalancerPoliciesResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeLoadBalancerPoliciesResponse.DescribeLoadBalancerPoliciesResult.PolicyDescriptions

    #private (parser DescribeLoadBalancerPolicies return)
    parserDescribeLoadBalancerPoliciesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeLoadBalancerPoliciesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeLoadBalancerPoliciesReturn


    #///////////////// Parser for DescribeLoadBalancerPolicyTypes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeLoadBalancerPolicyTypesResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeLoadBalancerPolicyTypesResponse.DescribeLoadBalancerPolicyTypesResult.PolicyTypeDescriptions

    #private (parser DescribeLoadBalancerPolicyTypes return)
    parserDescribeLoadBalancerPolicyTypesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeLoadBalancerPolicyTypesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeLoadBalancerPolicyTypesReturn


    #///////////////// Parser for DescribeLoadBalancers return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeLoadBalancersResult = ( result ) ->
        #resolve result
        #return vo
        result_set = ($.xml2json ($.parseXML result[1])).DescribeLoadBalancersResponse.DescribeLoadBalancersResult.LoadBalancerDescriptions

        result_set = resolvedObjectToArray result_set

        if result_set

            if result_set.member.constructor == Object

                tmp = result_set.member

                result_set = []

                result_set.push tmp

            else
                result_set = result_set.member

        result_set

    #private (parser DescribeLoadBalancers return)
    parserDescribeLoadBalancersReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeLoadBalancersResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeLoadBalancersReturn


    #############################################################
    #public
    parserDescribeInstanceHealthReturn       : parserDescribeInstanceHealthReturn
    parserDescribeLoadBalancerPoliciesReturn : parserDescribeLoadBalancerPoliciesReturn
    parserDescribeLoadBalancerPolicyTypesReturn : parserDescribeLoadBalancerPolicyTypesReturn
    parserDescribeLoadBalancersReturn        : parserDescribeLoadBalancersReturn
    resolveDescribeLoadBalancersResult       : resolveDescribeLoadBalancersResult
