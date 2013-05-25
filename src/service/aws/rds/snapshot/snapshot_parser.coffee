#*************************************************************************************
#* Filename     : snapshot_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:20
#* Description  : parser return data of snapshot
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'snapshot_vo', 'result_vo', 'constant' ], ( snapshot_vo, result_vo, constant ) ->


    #///////////////// Parser for DescribeDBSnapshots return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeDBSnapshotsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeDBSnapshots return)
    parserDescribeDBSnapshotsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeDBSnapshotsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeDBSnapshotsReturn


    #############################################################
    #public
    parserDescribeDBSnapshotsReturn          : parserDescribeDBSnapshotsReturn

