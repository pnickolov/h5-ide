
define [ 'constant'] , ( constant ) ->


    #private (resolve return_code for forge api)
    processForgeReturnHandler = ( result, return_code, param ) ->

        forge_result = {

            #orial
            return_code      : -1
            param            : null

            #resolved
            resolved_data    : null
            is_error         : true
            error_message    : ""

        }

        is_error         = true # only E_OK is false
        error_message    = ""
        resolved_data    = null

        try

            switch return_code
                when constant.RETURN_CODE.E_OK      then is_error      = false
                when constant.RETURN_CODE.E_NONE    then error_message = result.toString() #"Invalid username or password"
                when constant.RETURN_CODE.E_INVALID then error_message = result.toString() #"Invalid username or password"
                when constant.RETURN_CODE.E_EXPIRED then error_message = result.toString() #"Your subscription expired"
                when constant.RETURN_CODE.E_UNKNOWN then error_message = constant.MESSAGE_E.E_UNKNOWN #"Invalid username or password"
                else
                    error_message  =  result.toString()

        catch error
            error_message = error.toString()
            is_error = true

        finally

            #orial
            forge_result.return_code      = return_code
            forge_result.param            = param

            #resolved
            forge_result.is_error         = is_error
            forge_result.resolved_data    = resolved_data
            forge_result.error_message    = error_message

        #return vo
        forge_result
    # end of processForgeReturnHandler


    #private (resolve return_code for forge api)
    processAWSReturnHandler = ( result, return_code, param ) ->

        aws_result = {

            #orial
            return_code     : -1
            param           : null

            #resolved
            resolved_data       : null
            is_error            : true
            error_message       : ""
            aws_error_code      : -1
            aws_error_message   : ""
        }

        is_error          = true # only E_OK is false
        error_message     = ""
        resolved_data     = null

        aws_error_code    = ""
        aws_error_message = ""

        try

            switch return_code
                when constant.RETURN_CODE.E_OK      then is_error      = false
                when constant.RETURN_CODE.E_NONE    then error_message = result.toString() #"Invalid username or password"
                when constant.RETURN_CODE.E_INVALID then error_message = result.toString() #"Invalid username or password"
                when constant.RETURN_CODE.E_EXPIRED then error_message = result.toString() #"Your subscription expired"
                when constant.RETURN_CODE.E_UNKNOWN then error_message = constant.MESSAGE_E.E_UNKNOWN #"Invalid username or password"
                else
                    error_message  =  result.toString()

        catch error
            error_message = error.toString()
            is_error = true

        finally

            #orial
            aws_result.return_code       = return_code
            aws_result.param             = param

            #resolved
            aws_result.is_error          = is_error
            aws_result.resolved_data     = resolved_data
            aws_result.error_message     = error_message

            aws_result.aws_error_code    = aws_error_code
            aws_result.aws_error_message = aws_error_message


        #return vo
        aws_result
    # end of processForgeReturnHandler

    #public
    processForgeReturnHandler : processForgeReturnHandler
    processAWSReturnHandler   : processAWSReturnHandler

