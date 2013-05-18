
define [], () ->

    #private
    forge_result = {

        #orial
        return_code      : -1
        param            : null

        #resolved
        resolved_data    : null
        is_error         : true
        error_message    : ""

    }

    #private
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

    #public
    forge_result : forge_result
    aws_result   : aws_result