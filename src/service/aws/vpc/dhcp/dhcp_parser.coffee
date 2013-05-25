#*************************************************************************************
#* Filename     : dhcp_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:22
#* Description  : parser return data of dhcp
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'dhcp_vo', 'result_vo', 'constant' ], ( dhcp_vo, result_vo, constant ) ->


    #///////////////// Parser for DescribeDhcpOptions return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeDhcpOptionsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeDhcpOptions return)
    parserDescribeDhcpOptionsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeDhcpOptionsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeDhcpOptionsReturn


    #############################################################
    #public
    parserDescribeDhcpOptionsReturn          : parserDescribeDhcpOptionsReturn

