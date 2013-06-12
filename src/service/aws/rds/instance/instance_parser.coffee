#*************************************************************************************
#* Filename     : instance_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:18
#* Description  : parser return data of instance
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'instance_vo', 'result_vo', 'constant' ], ( instance_vo, result_vo, constant ) ->


    #///////////////// Parser for DescribeDBInstances return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeDBInstancesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeDBInstances return)
    parserDescribeDBInstancesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeDBInstancesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeDBInstancesReturn


    #############################################################
    #public
    parserDescribeDBInstancesReturn          : parserDescribeDBInstancesReturn

