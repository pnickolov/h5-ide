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

        NAVIGATION_COMPLETE : 'NAVIGATION_COMPLETE'
        HEADER_COMPLETE     : 'HEADER_COMPLETE'
        DESIGN_COMPLETE     : 'DESIGN_COMPLETE'

        constructor : ->
            _.extend this, Backbone.Events

        onListen : ( type ,callback ) ->
            this.once type, callback

    event = new Event()

    event
