###

###

define [ 'underscore', 'backbone' ], () ->

    ###
    #private
    event = {
        NAVIGATION_COMPLETE : 'NAVIGATION_COMPLETE'
    }
    
    #bind event to Backbone.Events
    _.extend event, Backbone.Events
    
    #public
    event
    ###

    class Event

        #temp
        NAVIGATION_COMPLETE : 'NAVIGATION_COMPLETE'
        HEADER_COMPLETE     : 'HEADER_COMPLETE'
        DESIGN_COMPLETE     : 'DESIGN_COMPLETE'

        #true
        OPEN_DASHBOARD      : 'OPEN_DASHBOARD'
        OPEN_STACK_TAB      : 'OPEN_STACK_TAB'

        constructor : ->
            _.extend this, Backbone.Events

        onListen : ( type ,callback ) ->
            this.once type, callback

        onLongListen : ( type ,callback ) ->
            this.on type, callback

    event = new Event()

    event
