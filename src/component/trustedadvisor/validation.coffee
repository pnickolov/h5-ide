#############################
#  validation
#############################

define [ 'event', 'component/trustedadvisor/validation/main',
         'backbone', 'jquery', 'underscore'
], ( ide_event ) ->

    #privte
    validComp = ( obj ) ->
        if MC.ta.instance.checkValue(obj)
            alert('trustedadvisor!')
            true
        else
            require [ 'component/trustedadvisor/main' ], ( trustedadvisor_main ) -> trustedadvisor_main.loadModule obj
            false

    validAll = ( obj ) ->
        if obj
            true
        else
            #ide_event.trigger ide_event.APP_VALID_FAILED xxx

    #public
    validComp : validComp
    validAll  : validAll