#*************************************************************************************
#* Filename     : ebs_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:07
#* Description  : parser return data of ebs
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
    #///////////////// Parser for CreateVolume return  /////////////////
    #private (parser CreateVolume return)
    parserCreateVolumeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserCreateVolumeReturn


    #///////////////// Parser for DeleteVolume return  /////////////////
    #private (parser DeleteVolume return)
    parserDeleteVolumeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserDeleteVolumeReturn


    #///////////////// Parser for AttachVolume return  /////////////////
    #private (parser AttachVolume return)
    parserAttachVolumeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserAttachVolumeReturn


    #///////////////// Parser for DetachVolume return  /////////////////
    #private (parser DetachVolume return)
    parserDetachVolumeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserDetachVolumeReturn


    #///////////////// Parser for DescribeVolumes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeVolumesResult = ( result ) ->
        #resolve result
        #return vo

        result = resolvedObjectToArray ($.xml2json ($.parseXML result[1])).DescribeVolumesResponse.volumeSet

        if result?.item?
            return result.item
        else
            return null

    #private (parser DescribeVolumes return)
    parserDescribeVolumesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeVolumesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeVolumesReturn


    #///////////////// Parser for DescribeVolumeAttribute return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeVolumeAttributeResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeVolumeAttributeResponse

    #private (parser DescribeVolumeAttribute return)
    parserDescribeVolumeAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeVolumeAttributeResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeVolumeAttributeReturn


    #///////////////// Parser for DescribeVolumeStatus return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeVolumeStatusResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeVolumeStatusResponse

    #private (parser DescribeVolumeStatus return)
    parserDescribeVolumeStatusReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeVolumeStatusResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeVolumeStatusReturn


    #///////////////// Parser for ModifyVolumeAttribute return  /////////////////
    #private (parser ModifyVolumeAttribute return)
    parserModifyVolumeAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserModifyVolumeAttributeReturn


    #///////////////// Parser for EnableVolumeIO return  /////////////////
    #private (parser EnableVolumeIO return)
    parserEnableVolumeIOReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserEnableVolumeIOReturn


    #///////////////// Parser for CreateSnapshot return  /////////////////
    #private (parser CreateSnapshot return)
    parserCreateSnapshotReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserCreateSnapshotReturn


    #///////////////// Parser for DeleteSnapshot return  /////////////////
    #private (parser DeleteSnapshot return)
    parserDeleteSnapshotReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserDeleteSnapshotReturn


    #///////////////// Parser for ModifySnapshotAttribute return  /////////////////
    #private (parser ModifySnapshotAttribute return)
    parserModifySnapshotAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserModifySnapshotAttributeReturn


    #///////////////// Parser for ResetSnapshotAttribute return  /////////////////
    #private (parser ResetSnapshotAttribute return)
    parserResetSnapshotAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserResetSnapshotAttributeReturn


    #///////////////// Parser for DescribeSnapshots return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeSnapshotsResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeSnapshotsResponse.snapshotSet

    #private (parser DescribeSnapshots return)
    parserDescribeSnapshotsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeSnapshotsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeSnapshotsReturn


    #///////////////// Parser for DescribeSnapshotAttribute return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeSnapshotAttributeResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeSnapshotAttributeResponse

    #private (parser DescribeSnapshotAttribute return)
    parserDescribeSnapshotAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeSnapshotAttributeResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeSnapshotAttributeReturn


    #############################################################
    #public
    {
        parserCreateVolumeReturn                 : parserCreateVolumeReturn
        parserDeleteVolumeReturn                 : parserDeleteVolumeReturn
        parserAttachVolumeReturn                 : parserAttachVolumeReturn
        parserDetachVolumeReturn                 : parserDetachVolumeReturn
        parserDescribeVolumesReturn              : parserDescribeVolumesReturn
        parserDescribeVolumeAttributeReturn      : parserDescribeVolumeAttributeReturn
        parserDescribeVolumeStatusReturn         : parserDescribeVolumeStatusReturn
        parserModifyVolumeAttributeReturn        : parserModifyVolumeAttributeReturn
        parserEnableVolumeIOReturn               : parserEnableVolumeIOReturn
        parserCreateSnapshotReturn               : parserCreateSnapshotReturn
        parserDeleteSnapshotReturn               : parserDeleteSnapshotReturn
        parserModifySnapshotAttributeReturn      : parserModifySnapshotAttributeReturn
        parserResetSnapshotAttributeReturn       : parserResetSnapshotAttributeReturn
        parserDescribeSnapshotsReturn            : parserDescribeSnapshotsReturn
        parserDescribeSnapshotAttributeReturn    : parserDescribeSnapshotAttributeReturn
        resolveDescribeVolumesResult             : resolveDescribeVolumesResult
        resolveDescribeSnapshotsResult           : resolveDescribeSnapshotsResult
    }
