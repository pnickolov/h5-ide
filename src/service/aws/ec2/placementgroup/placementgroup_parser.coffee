#*************************************************************************************
#* Filename     : placementgroup_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:14
#* Description  : parser return data of placementgroup
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->


    #///////////////// Parser for CreatePlacementGroup return  /////////////////
    #private (parser CreatePlacementGroup return)
    parserCreatePlacementGroupReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserCreatePlacementGroupReturn


    #///////////////// Parser for DeletePlacementGroup return  /////////////////
    #private (parser DeletePlacementGroup return)
    parserDeletePlacementGroupReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserDeletePlacementGroupReturn


    #///////////////// Parser for DescribePlacementGroups return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribePlacementGroupsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribePlacementGroups return)
    parserDescribePlacementGroupsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribePlacementGroupsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribePlacementGroupsReturn


    #############################################################
    #public
    parserCreatePlacementGroupReturn         : parserCreatePlacementGroupReturn
    parserDeletePlacementGroupReturn         : parserDeletePlacementGroupReturn
    parserDescribePlacementGroupsReturn      : parserDescribePlacementGroupsReturn

