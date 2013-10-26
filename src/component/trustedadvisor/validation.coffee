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
                    resultVO.add type, result.level, result.info, result.uid
                    false
                return result
            else
                console.log 'func not found'

        catch error
            console.log "validComp error #{ error }"

    validAll = ( obj ) ->
        components = MC.canvas_data.component

        _.each components, ( component , id ) ->
            typeName = _.last component.type.split '.'
            type = typeName.toLowerCase()

            _.each validation_main[ type ], ( func, funcName ) ->
                result = func.call validation_main[ type ], id
                resultVO.add funcName, result.level, result.info

        resultVO




    #public
    validComp : validComp
    validAll  : validAll