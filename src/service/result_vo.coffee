
define [ 'constant', 'underscore' ] , ( constant, _ ) ->

    genSuccessHandler = ( api_name, src, param_ary, parser, callback ) ->
        ( res ) ->
            result = res.result[1]
            return_code = res.result[0]
            #resolve result
            param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
            aws_result = {}
            aws_result = parser result, return_code, param_ary

            if callback
                callback aws_result
                null
            else
                aws_result

    genErrorHandler = ( api_name, src, param_ary, parser, callback ) ->
        ( res ) ->
            result = res.result[1]
            return_code = res.result[0]

            aws_result = {}
            aws_result.return_code      = return_code
            aws_result.is_error         = true
            aws_result.error_message    = result.toString()

            param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
            aws_result.param = param_ary
            if callback
                callback aws_result
                null
            else
                aws_result



    genSendRequest =  ( url ) ->

        ( api_name, src, param_ary, parser, callback ) ->
            successHandler = genSuccessHandler.apply null, arguments
            errorHandler = genErrorHandler.apply null, arguments

            MC.api({
                url     : url
                method  : api_name
                data    : param_ary
            }).then successHandler, errorHandler


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
                when constant.RETURN_CODE.E_PARAM, 404, 405
                    errObj = parseAWSError result
                    error_message = errObj.errMessage
                    aws_error_code = errObj.errCode
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

    #private
    parseAWSError = ( result ) ->

        error_message = ''
        errCodeStr = ''

        if _.isArray(result) and result.length == 2

            err_code = result[0]
            err_xml  = result[1]

            errCodeXML = $($.parseXML(err_xml)).find('Error').find('Code')
            errMessageXML = $($.parseXML(err_xml)).find('Error').find('Message')

            if ( 400 <= err_code < 500 ) and errCodeXML.length == 1 and errMessageXML.length == 1

                errCodeStr = errCodeXML.text()

                switch errCodeStr

                    when 'InvalidAMIID.NotFound' then error_message = errMessageXML.text()

                    else

                        error_message = $($.parseXML(err_xml)).find('Error').find('Message').text()

        else if _.isString(result)

            error_message = result

        #return
        errCode: errCodeStr
        errMessage: error_message

    #public
    processForgeReturnHandler : processForgeReturnHandler
    processAWSReturnHandler   : processAWSReturnHandler
    genSendRequest            : genSendRequest

