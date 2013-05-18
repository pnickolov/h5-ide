
define [], () ->

    #private
    forge_result = {

        #orial
        return_code      : -1
        param            : null

        #resolved
        resolved_data    : null
        resolved_message : ""
        is_error         : true
    }

    #private
    aws_result = {

        #orial
        param           : null

        #resolved
        resolved_data   : null
        is_error        : true
        error_code      : null
        error_message   : null
    }

    #public
    forge_result : forge_result
    aws_result   : aws_result