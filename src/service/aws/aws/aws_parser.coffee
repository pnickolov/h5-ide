#*************************************************************************************
#* Filename     : aws_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:05
#* Description  : parser return data of aws
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'aws_vo', 'result_vo', 'constant', 'ebs_parser', 'eip_parser', 'instance_parser'
         'keypair_parser', 'securitygroup_parser', 'elb_parser', 'iam_parser', 'acl_parser'
         'customergateway_parser', 'dhcp_parser', 'eni_parser', 'internetgateway_parser', 'routetable_parser'
         'subnet_parser', 'vpc_parser', 'vpn_parser', 'vpngateway_parser', 'ec2_parser', 'ami_parser' ], ( aws_vo, result_vo, constant, ebs_parser, eip_parser, instance_parser
         keypair_parser, securitygroup_parser, elb_parser, iam_parser, acl_parser
         customergateway_parser, dhcp_parser, eni_parser, internetgateway_parser, routetable_parser
         subnet_parser, vpc_parser, vpn_parser, vpngateway_parser, ec2_parser, ami_parser) ->


    #///////////////// Parser for quickstart return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveQuickstartResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser quickstart return)
    parserQuickstartReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveQuickstartResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserQuickstartReturn


    #///////////////// Parser for Public return (need resolve) /////////////////
    #private (resolve result to vo )
    resolvePublicResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser Public return)
    parserPublicReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolvePublicResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserPublicReturn


    #///////////////// Parser for info return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInfoResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser info return)
    parserInfoReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveInfoResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserInfoReturn


    #///////////////// Parser for resource return (need resolve) /////////////////
    resourceMap = ( result ) ->
        responses = {
            "DescribeImagesResponse"               :   ami_parser.resolveDescribeImagesResult
            "DescribeAvailabilityZonesResponse"    :   ec2_parser.resolveDescribeAvailabilityZonesResult
            "DescribeVolumesResponse"              :   ebs_parser.resolveDescribeVolumesResult
            "DescribeSnapshotsResponse"            :   ebs_parser.resolveDescribeSnapshotsResult
            "DescribeAddressesResponse"            :   eip_parser.resolveDescribeAddressesResult
            "DescribeInstancesResponse"            :   instance_parser.resolveDescribeInstancesResult
            "DescribeKeyPairsResponse"             :   keypair_parser.resolveDescribeKeyPairsResult
            "DescribeSecurityGroupsResponse"       :   securitygroup_parser.resolveDescribeSecurityGroupsResult
            "DescribeLoadBalancersResponse"        :   elb_parser.resolveDescribeLoadBalancersResult
            "DescribeNetworkAclsResponse"          :   acl_parser.resolveDescribeNetworkAclsResult
            "DescribeCustomerGatewaysResponse"     :   customergateway_parser.resolveDescribeCustomerGatewaysResult
            "DescribeDhcpOptionsResponse"          :   dhcp_parser.resolveDescribeDhcpOptionsResult
            "DescribeNetworkInterfacesResponse"    :   eni_parser.resolveDescribeNetworkInterfacesResult
            "DescribeInternetGatewaysResponse"     :   internetgateway_parser.resolveDescribeInternetGatewaysResult
            "DescribeRouteTablesResponse"          :   routetable_parser.resolveDescribeRouteTablesResult
            "DescribeSubnetsResponse"              :   subnet_parser.resolveDescribeSubnetsResult
            "DescribeVpcsResponse"                 :   vpc_parser.resolveDescribeVpcsResult
            "DescribeVpnConnectionsResponse"       :   vpn_parser.resolveDescribeVpnConnectionsResult
            "DescribeVpnGatewaysResponse"          :   vpngateway_parser.resolveDescribeVpnGatewaysResult
        }

        dict = {}

        for node in result

            action_name = ($.parseXML node).documentElement.localName

            dict_name = action_name.replace /Response/i, ""

            dict[dict_name] = [] if dict[dict_name]?

            dict[dict_name] = responses[action_name] [null, node]

        dict


    #private (resolve result to vo )
    resolveResourceResult = ( result ) ->
        #resolve result
        #return vo
        res = {}
        res[region] = resourceMap nodes for region, nodes of result


        res

    #private (parser resource return)
    parserResourceReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveResourceResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserResourceReturn


    #///////////////// Parser for price return (need resolve) /////////////////
    #private (resolve result to vo )
    resolvePriceResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser price return)
    parserPriceReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolvePriceResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserPriceReturn


    #///////////////// Parser for status return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveStatusResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        $.parseJSON result[2]

    #private (parser status return)
    parserStatusReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveStatusResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserStatusReturn


    #############################################################
    #public
    parserQuickstartReturn                   : parserQuickstartReturn
    parserPublicReturn                       : parserPublicReturn
    parserInfoReturn                         : parserInfoReturn
    parserResourceReturn                     : parserResourceReturn
    parserPriceReturn                        : parserPriceReturn
    parserStatusReturn                       : parserStatusReturn
    resourceMap                              : resourceMap
