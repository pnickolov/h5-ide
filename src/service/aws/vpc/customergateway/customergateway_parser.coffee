#*************************************************************************************
#* Filename     : customergateway_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:22
#* Description  : parser return data of customergateway
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'customergateway_vo', 'result_vo', 'constant' ], ( customergateway_vo, result_vo, constant ) ->


    #///////////////// Parser for DescribeCustomerGateways return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeCustomerGatewaysResult = ( result ) ->
        #return
        ($.xml2json ($.parseXML result[1])).DescribeCustomerGatewaysResponse.customerGatewaySet

    #private (parser DescribeCustomerGateways return)
    parserDescribeCustomerGatewaysReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeCustomerGatewaysResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeCustomerGatewaysReturn


    #############################################################
    #public
    parserDescribeCustomerGatewaysReturn     : parserDescribeCustomerGatewaysReturn
    resolveDescribeCustomerGatewaysResult    : resolveDescribeCustomerGatewaysResult
