#############################
#  validation
#############################

define [ 'constant', 'event', './validation/main', './validation/result_vo',
         'jquery', 'underscore'
], ( constant, ide_event, validation_main, resultVO ) ->

    #privte
    validComp = ( type ) ->

        try

            #test
            MC.ta.resultVO = resultVO

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

    validAll = ->

        components = MC.canvas_data.component

        _.each components, ( component , uid ) ->

            filename = _.last component.type.split '.'
            filename = filename.toLowerCase()

            _.each validation_main[ filename ], ( func, method ) ->
                if needValid filename, func, component
                    validComp filename + '.' + method, uid

        resultVO.result()


    validList =
        instance:
            all: ( component ) ->
                true
            isEBSOptimizedForAttachedProvisionedVolume: ( component ) ->
                true
        vpc:
            all: ( component ) ->
                true


    needValid = ( filename, funcName, component ) ->
        fileNeed = validList[ filename ]

        if fileNeed
            allNeed     = isNeeded fileNeed, 'all', component
            funcNeed    = isNeeded fileNeed, funcName, component
            return allNeed and funcNeed
        else
            return true


    isNeeded = ( obj, key, params ) ->
        not obj[ key ] or obj[ key ]( params )





    #public
    validComp : validComp
    validAll  : validAll
    needValid : needValid

