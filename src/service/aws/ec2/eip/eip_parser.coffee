#*************************************************************************************
#* Filename     : eip_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:10
#* Description  : parser return data of eip
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'eip_vo', 'result_vo', 'constant' ], ( eip_vo, result_vo, constant ) ->


    #///////////////// Parser for AllocateAddress return  /////////////////
    #private (parser AllocateAddress return)
    parserAllocateAddressReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserAllocateAddressReturn


    #///////////////// Parser for ReleaseAddress return  /////////////////
    #private (parser ReleaseAddress return)
    parserReleaseAddressReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserReleaseAddressReturn


    #///////////////// Parser for AssociateAddress return  /////////////////
    #private (parser AssociateAddress return)
    parserAssociateAddressReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserAssociateAddressReturn


    #///////////////// Parser for DisassociateAddress return  /////////////////
    #private (parser DisassociateAddress return)
    parserDisassociateAddressReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserDisassociateAddressReturn


    #///////////////// Parser for DescribeAddresses return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAddressesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeAddresses return)
    parserDescribeAddressesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeAddressesResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeAddressesReturn


    #############################################################
    #public
    parserAllocateAddressReturn              : parserAllocateAddressReturn
    parserReleaseAddressReturn               : parserReleaseAddressReturn
    parserAssociateAddressReturn             : parserAssociateAddressReturn
    parserDisassociateAddressReturn          : parserDisassociateAddressReturn
    parserDescribeAddressesReturn            : parserDescribeAddressesReturn

