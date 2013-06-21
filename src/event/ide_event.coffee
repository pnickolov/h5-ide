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

        #
        ADD_STACK_TAB       : 'ADD_STACK_TAB'
        OPEN_STACK_TAB      : 'OPEN_STACK_TAB'
        OPEN_APP_TAB        : 'OPEN_APP_TAB'
        #
        SWITCH_TAB          : 'SWITCH_TAB'
        SWITCH_DASHBOARD    : 'SWITCH_DASHBOARD'

        TERMINATE_APP_TAB   : 'TERMINATE_APP_TAB'

        #result app stack region empty_region list
        RESULT_APP_LIST     : 'RESULT_APP_LIST'
        RESULT_STACK_LIST   : 'RESULT_STACK_LIST'
        RESULT_EMPTY_REGION_LIST  : 'RESULT_EMPTY_REGION_LIST'

        #return overview region tab
        RETURN_OVERVIEW_TAB : 'RETURN_OVERVIEW_TAB'
        RETURN_REGION_TAB   : 'RETURN_REGION_TAB'

        #app/stack in region
        APP_RUN             : 'APP_RUN'
        APP_STOP            : 'APP_STOP'
        APP_TERMINATE       : 'APP_TERMINATE'
        UPDATE_APP_LIST     : 'UPDATE_APP_LIST'
        UPDATE_STACK_LIST   : 'UPDATE_STACK_LIST'
        STACK_DELETE        : 'STACK_DELETE'

        constructor : ->
            _.extend this, Backbone.Events

        onListen : ( type ,callback ) ->
            this.once type, callback

        onLongListen : ( type ,callback ) ->
            this.on type, callback

    event = new Event()

    event
