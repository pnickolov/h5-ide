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
        DASHBOARD_COMPLETE  : 'DASHBOARD_COMPLETE'
        DESIGN_COMPLETE     : 'DESIGN_COMPLETE'
        RESOURCE_COMPLETE   : 'RESOURCE_COMPLETE'
        DESIGN_SUB_COMPLETE : 'DESIGN_SUB_COMPLETE'
        #
        RELOAD_RESOURCE     : 'RELOAD_RESOURCE'
        OPEN_PROPERTY       : 'OPEN_PROPERTY'
        UPDATE_PROPERTY     : 'UPDATE_PROPERTY'
        OPEN_SG             : 'OPEN_SG'
        OPEN_ACL            : 'OPEN_ACL'
        RELOAD_PROPERTY     : 'RELOAD_PROPERTY'
        RELOAD_AZ           : 'RELOAD_AZ'

        # User Input Change Event
        NEED_IGW              : 'NEED_IGW'
        ENABLE_RESOURCE_ITEM  : 'ENABLE_RESOURCE_ITEM'
        DISABLE_RESOURCE_ITEM : 'DISABLE_RESOURCE_ITEM'

        DELETE_COMPONENT      : 'DELETE_COMPONENT'

        PROPERTY_TITLE_CHANGE  : 'PROPERTY_TITLE_CHANGE'
        PROPERTY_OPEN_SUBPANEL : 'PROPERTY_OPEN_SUBPANEL'
        PROPERTY_HIDE_SUBPANEL : 'PROPERTY_HIDE_SUBPANEL'

        CANVAS_CREATE_LINE  : 'CANVAS_CREATE_LINE'
        CANVAS_DELETE_OBJECT: 'CANVAS_DELETE_OBJECT'

        CREATE_LINE_TO_CANVAS:'CREATE_LINE_TO_CANVAS'
        DELETE_LINE_TO_CANVAS:'DELETE_LINE_TO_CANVAS'

        REDRAW_SG_LINE      : 'REDRAW_SG_LINE'
        UPDATE_SG_LINE      : 'UPDATE_SG_LINE'
        #
        ADD_STACK_TAB       : 'ADD_STACK_TAB'
        OPEN_STACK_TAB      : 'OPEN_STACK_TAB'
        OPEN_APP_TAB        : 'OPEN_APP_TAB'
        OPEN_APP_PROCESS_TAB: 'OPEN_APP_PROCESS_TAB'
        PROCESS_RUN_SUCCESS : 'PROCESS_RUN_SUCCESS'
        #
        SWITCH_TAB          : 'SWITCH_TAB'
        SWITCH_DASHBOARD    : 'SWITCH_DASHBOARD'
        SWITCH_APP_PROCESS  : 'SWITCH_APP_PROCESS'
        SWITCH_LOADING_BAR  : 'SWITCH_LOADING_BAR'
        SWITCH_MAIN         : 'SWITCH_MAIN'

        TERMINATE_APP_TAB   : 'TERMINATE_APP_TAB'

        SAVE_DESIGN_MODULE  : 'SAVE_DESIGN_MODULE'

        UPDATE_TABBAR       : 'UPDATE_TABBAR'
        UPDATE_TAB_DATA     : 'UPDATE_TAB_DATA'
        DELETE_TAB_DATA     : 'DELETE_TAB_DATA'
        UPDATE_TAB_ICON     : 'UPDATE_TAB_ICON'
        UPDATE_REGION_THUMBNAIL : 'UPDATE_REGION_THUMBNAIL'

        #result app stack region empty_region list
        RESULT_APP_LIST     : 'RESULT_APP_LIST'
        RESULT_STACK_LIST   : 'RESULT_STACK_LIST'
        RESULT_EMPTY_REGION_LIST  : 'RESULT_EMPTY_REGION_LIST'

        #return overview region tab
        RETURN_OVERVIEW_TAB : 'RETURN_OVERVIEW_TAB'
        RETURN_REGION_TAB   : 'RETURN_REGION_TAB'

        #app/stack operation
        START_APP           : 'START_APP'
        STOP_APP            : 'STOP_APP'
        TERMINATE_APP       : 'TERMINATE_APP'
        DELETE_STACK        : 'DELETE_STACK'
        DUPLICATE_STACK     : 'DUPLICATE_STACK'
        SAVE_STACK          : 'SAVE_STACK'
        UPDATE_APP_LIST     : 'UPDATE_APP_LIST'
        UPDATE_STACK_LIST   : 'UPDATE_STACK_LIST'

        #app/stack state
        STARTED_APP         : 'STARTED_APP'
        STOPPED_APP         : 'STOPPED_APP'
        TERMINATED_APP      : 'TERMINATED_APP'
        STACK_DELETE        : 'STACK_DELETE'

        #canvas event
        CANVAS_SAVE         : 'CANVAS_SAVE' #save stack/app by ctrl+s

        #navigation to dashboard - region
        NAVIGATION_TO_DASHBOARD_REGION : 'NAVIGATION_TO_DASHBOARD_REGION'

        #websocket meteor collection
        WS_COLLECTION_READY_REQUEST : 'WS_COLLECTION_READY_REQUEST'

        #quickstart data ready
        RESOURCE_QUICKSTART_READY : 'RESOURCE_QUICKSTART_READY'

        #trigger property view's undelegateEvents
        UNDELEGATE_PROPERTY_DOM_EVENTS : 'UNDELEGATE_PROPERTY_DOM_EVENTS'

        #app ready and generate thumbnail
        SAVE_APP_THUMBNAIL  :   'SAVE_APP_THUMBNAIL'

        #update process
        UPDATE_PROCESS      :   'UPDATE_PROCESS'

        #update header
        UPDATE_HEADER       :   'UPDATE_HEADER'

        #refresh region resource
        UPDATE_REGION_RESOURCE      :       'UPDATE_REGION_RESOURCE'

        #updated aws credential
        UPDATE_AWS_CREDENTIAL       :       'UPDATE_AWS_CREDENTIAL'

        constructor : ->
            _.extend this, Backbone.Events

        onListen : ( type ,callback ) ->
            this.once type, callback

        onLongListen : ( type ,callback ) ->
            this.on type, callback

        offListen : ( type, function_name ) ->
            if function_name then this.off type, function_name else this.off type

    event = new Event()

    event
