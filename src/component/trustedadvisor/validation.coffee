#############################
#  validation
#############################

define [ 'event', 'component/trustedadvisor/validation/main',
         'jquery', 'underscore'
], ( ide_event, validation_main ) ->

    #privte
    validComp = ( type, obj ) ->
        temp     = type.split '.'
        filename = temp[ 0 ]
        method   = temp[ 1 ]
        func     = validation_main[ filename ][ method ]

        if _.isFunction func

            if func obj
                console.log 'validation success'
                true
            else
                #require [ 'component/trustedadvisor/main' ], ( trustedadvisor_main ) -> trustedadvisor_main.loadModule obj
                console.log 'validation failed'
                false

        else
            console.log 'func not found'

        #if MC.ta.instance.checkValue(obj)
        #    alert('trustedadvisor!')
        #    true
        #else
        #    require [ 'component/trustedadvisor/main' ], ( trustedadvisor_main ) -> trustedadvisor_main.loadModule obj
        #    false

    validAll = ( obj ) ->
        if obj
            true
        else
            #ide_event.trigger ide_event.APP_VALID_FAILED xxx

    #public
    validComp : validComp
    validAll  : validAll