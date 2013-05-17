
define [], () ->

    #private
    forge_result_vo = {

        #orial
        return_code      : -1
        param            : null

        #resolved
        resolved_data    : null
        resolved_message : ""
        is_error         : true
    }

    #private
    aws_result_vo = {

        #orial
        param           : null

        #resolved
        resolved_data   : null
        is_error        : true
        error_code      : null
        error_message   : null
    }

    #public
    forge_result_vo : forge_result_vo
    aws_result_vo   : aws_result_vo