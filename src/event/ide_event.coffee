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
        ADD_STACK_TAB       : 'ADD_STACK_TAB'
        OPEN_STACK_TAB      : 'OPEN_STACK_TAB'
        OPEN_APP_TAB        : 'OPEN_APP_TAB'
        SWITCH_STACK_TAB    : 'SWITCH_STACK_TAB'
        SWITCH_DASHBOARD    : 'SWITCH_DASHBOARD'

        #result app stack region empty_region list
        RESULT_APP_LIST     : 'RESULT_APP_LIST'
        RESULT_STACK_LIST   : 'RESULT_STACK_LIST'
        RESULT_EMPTY_REGION_LIST  : 'RESULT_EMPTY_REGION_LIST'

        #return overview region tab
        RETURN_OVERVIEW_TAB : 'RETURN_OVERVIEW_TAB'
        RETURN_REGION_TAB   : 'RETURN_REGION_TAB'

        #click operation of app/stack in region
        CLICK_RUN_APP       : 'CLICK_RUN_APP'
        CLICK_STOP_APP      : 'CLICK_STOP_APP'
        CLICK_TERMINAL_APP  : 'CLICK_TERMINAL_APP'
        CLICK_DUPLICATE_STACK   : 'CLICK_DUPLICATE_STACK'
        CLICK_DELETE_STACK  : 'CLICK_DELETE_STACK'

        constructor : ->
            _.extend this, Backbone.Events

        onListen : ( type ,callback ) ->
            this.once type, callback

        onLongListen : ( type ,callback ) ->
            this.on type, callback

    event = new Event()

    event
