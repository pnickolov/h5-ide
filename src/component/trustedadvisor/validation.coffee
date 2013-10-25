#############################
#  validation
#############################

define [ 'event', './validation/main', './validation/result_vo',
         'jquery', 'underscore'
], ( ide_event, validation_main, resultVO ) ->

    #privte
    validComp = ( type ) ->

        try

            temp     = type.split '.'
            filename = temp[ 0 ]
            method   = temp[ 1 ]
            func     = validation_main[ filename ][ method ]

            if _.isFunction func

                args = Array.prototype.slice.call arguments, 1
                result = func.apply validation_main[ filename ], args

                if !result
                    resultVO.del type
                    true
                else
                    resultVO.add type, result.level, result.info
                    false
                return result
            else
                console.log 'func not found'

        catch error
            console.log "validComp error #{ error }"

    validAll = ( obj ) ->
        #validComp 'instance.checkValue', uid
        #validComp 'instance.bbb', uid
        #validComp 'instance.ccc', uid

    #public
    validComp : validComp
    validAll  : validAll