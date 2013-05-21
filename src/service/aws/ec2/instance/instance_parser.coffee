
define [ 'MC', 'jquery', 'instance_vo', 'result_vo', 'constant' ], ( MC, $, instance_vo, result_vo, constant ) ->

    #private (resolve result to instance_vo.instance )
    resolveVO = ( result ) ->
        #resolve result

        xml = $.parseXML result
        instance_vo.instance = $.xml2json xml

        #for debug
        #console.info instance_vo.instance

        #return instance
        instance_vo.instance

    #private (parser login return)
    parseDescribeInstancesResponse = ( result, return_code, param ) ->

        is_error          = true # only E_OK is false
        error_message     = ""
        resolved_data     = null

        aws_error_code    = -1
        aws_error_message = ""

        try

            switch return_code
                when constant.RETURN_CODE.E_OK
                    resolved_data  = resolveVO result[1]
                    is_error       = false
                else
                    error_message  = result.toString()

        catch error
            error_message = error.toString()
            is_error      = true

        finally

            #orial
            result_vo.aws_result.return_code       = return_code
            result_vo.aws_result.param             = param

            #resolved
            result_vo.aws_result.is_error          = is_error
            result_vo.aws_result.resolved_data     = resolved_data
            result_vo.aws_result.error_message     = error_message

            result_vo.aws_result.aws_error_code    = aws_error_code
            result_vo.aws_result.aws_error_message = aws_error_message


        #return vo
        result_vo.aws_result
    # end of parseLoginResult


    #public
    parseDescribeInstancesResponse : parseDescribeInstancesResponse