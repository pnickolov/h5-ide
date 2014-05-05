###

###

define [ 'underscore', 'backbone' ], () ->

    class Event

        constructor : ->
            _.extend this, Backbone.Events

        #module
        NAVIGATION_COMPLETE    : 'NAVIGATION_COMPLETE'
        HEADER_COMPLETE        : 'HEADER_COMPLETE'
        DASHBOARD_COMPLETE     : 'DASHBOARD_COMPLETE'
        DESIGN_COMPLETE        : 'DESIGN_COMPLETE'
        RESOURCE_COMPLETE      : 'RESOURCE_COMPLETE'
        DESIGN_SUB_COMPLETE    : 'DESIGN_SUB_COMPLETE'

        IDE_AVAILABLE          : 'IDE_AVAILABLE'

        #
        LOGOUT_IDE             : 'LOGOUT_IDE'

        #
        OPEN_DESIGN            : 'OPEN_DESIGN'
        OPEN_SUB_DESIGN        : 'OPEN_SUB_DESIGN'
        CREATE_DESIGN_OBJ      : 'CREATE_DESIGN_OBJ'
        OPEN_PROPERTY          : 'OPEN_PROPERTY'
        FORCE_OPEN_PROPERTY    : "FORCE_OPEN_PROPERTY"
        REFRESH_PROPERTY       : "REFRESH_PROPERTY"
        RELOAD_AZ              : 'RELOAD_AZ'
        RESOURCE_API_COMPLETE  : 'RESOURCE_API_COMPLETE'
        #OPEN_TOOLBAR          : 'OPEN_TOOLBAR'
        #OPEN_DESIGN_0          : 'OPEN_DESIGN_0'

        #design overlay
        SHOW_DESIGN_OVERLAY    : 'SHOW_DESIGN_OVERLAY'
        HIDE_DESIGN_OVERLAY    : 'HIDE_DESIGN_OVERLAY'

        #resource panel
        UPDATE_RESOURCE_STATE  : 'UPDATE_RESOURCE_STATE'

        #switch
        SWITCH_TAB             : 'SWITCH_TAB'
        SWITCH_DASHBOARD       : 'SWITCH_DASHBOARD'
        SWITCH_PROCESS         : 'SWITCH_PROCESS'
        SWITCH_LOADING_BAR     : 'SWITCH_LOADING_BAR'
        SWITCH_WAITING_BAR     : 'SWITCH_WAITING_BAR'
        SWITCH_MAIN            : 'SWITCH_MAIN'

        #tab
        ADD_TAB_DATA           : 'ADD_TAB_DATA'
        DELETE_TAB_DATA        : 'DELETE_TAB_DATA'
        UPDATE_TAB_DATA        : 'UPDATE_TAB_DATA'
        #UPDATE_TAB_CLOSE_STATE: 'UPDATE_TAB_CLOSE_STATE'

        #tabbar
        OPEN_DESIGN_TAB        : 'OPEN_DESIGN_TAB'
        CLOSE_DESIGN_TAB       : 'CLOSE_DESIGN_TAB'
        UPDATE_DESIGN_TAB      : 'UPDATE_DESIGN_TAB'
        UPDATE_DESIGN_TAB_ICON : 'UPDATE_DESIGN_TAB_ICON'
        UPDATE_DESIGN_TAB_TYPE : 'UPDATE_DESIGN_TAB_TYPE'

        #ADD_STACK_TAB         : 'ADD_STACK_TAB'
        #OPEN_STACK_TAB        : 'OPEN_STACK_TAB'
        #OPEN_APP_TAB          : 'OPEN_APP_TAB'
        #OPEN_APP_PROCESS_TAB  : 'OPEN_APP_PROCESS_TAB'

        #PROCESS_RUN_SUCCESS   : 'PROCESS_RUN_SUCCESS'
        #RELOAD_STACK_TAB      : 'RELOAD_STACK_TAB'
        #RELOAD_NEW_STACK_TAB  : 'RELOAD_NEW_STACK_TAB'
        #TERMINATE_APP_TAB     : 'TERMINATE_APP_TAB'

        #status bar & ta
        HIDE_STATUS_BAR        : 'HIDE_STATUS_BAR'
        UPDATE_STATUS_BAR      : 'UPDATE_STATUS_BAR'
        UPDATE_TA_MODAL        : 'UPDATE_TA_MODAL'
        UNLOAD_TA_MODAL        : 'UNLOAD_TA_MODAL'
        TA_SYNC_START          : 'TA_SYNC_START'
        TA_SYNC_FINISH         : 'TA_SYNC_FINISH'

        #result app stack region empty_region list
        RESULT_APP_LIST        : 'RESULT_APP_LIST'
        RESULT_STACK_LIST      : 'RESULT_STACK_LIST'
        RESULT_EMPTY_REGION_LIST  : 'RESULT_EMPTY_REGION_LIST'
        UPDATE_DASHBOARD       : 'UPDATE_DASHBOARD'
        UPDATE_REGION_THUMBNAIL: 'UPDATE_REGION_THUMBNAIL'

        #return overview region tab
        RETURN_OVERVIEW_TAB    : 'RETURN_OVERVIEW_TAB'
        RETURN_REGION_TAB      : 'RETURN_REGION_TAB'

        #appedit
        APPEDIT_2_APP          : 'APPEDIT_2_APP'
        RESTORE_CANVAS         : 'RESTORE_CANVAS'
        #APPEDIT_UPDATE_ERROR  : 'APPEDIT_UPDATE_ERROR'

        # User Input Change Event
        ENABLE_RESOURCE_ITEM   : 'ENABLE_RESOURCE_ITEM'
        DISABLE_RESOURCE_ITEM  : 'DISABLE_RESOURCE_ITEM'

        # property
        SHOW_PROPERTY_PANEL    : 'SHOW_PROPERTY_PANEL'
        PROPERTY_REFRESH_ENI_IP_LIST : 'PROPERTY_REFRESH_ENI_IP_LIST'
        PROPERTY_DISABLE_USER_DATA_INPUT : 'PROPERTY_DISABLE_USER_DATA_INPUT'
        #trigger property view's undelegateEvents
        UNDELEGATE_PROPERTY_DOM_EVENTS : 'UNDELEGATE_PROPERTY_DOM_EVENTS'

        CANVAS_CREATE_LINE     : 'CANVAS_CREATE_LINE'
        CANVAS_DELETE_OBJECT   : 'CANVAS_DELETE_OBJECT'

        #when get instance info by DescribeInstances in ASG
        CANVAS_UPDATE_APP_RESOURCE  : 'CANVAS_UPDATE_APP_RESOURCE'

        CREATE_LINE_TO_CANVAS  : 'CREATE_LINE_TO_CANVAS'
        DELETE_LINE_TO_CANVAS  : 'DELETE_LINE_TO_CANVAS'

        REDRAW_SG_LINE         : 'REDRAW_SG_LINE'
        UPDATE_SG_LINE         : 'UPDATE_SG_LINE'

        #app/stack operation
        START_APP              : 'START_APP'
        STOP_APP               : 'STOP_APP'
        TERMINATE_APP          : 'TERMINATE_APP'
        DELETE_STACK           : 'DELETE_STACK'
        DUPLICATE_STACK        : 'DUPLICATE_STACK'
        APP_TO_STACK           : 'APP_TO_STACK'
        SAVE_STACK             : 'SAVE_STACK'
        UPDATE_APP_LIST        : 'UPDATE_APP_LIST'
        UPDATE_STACK_LIST      : 'UPDATE_STACK_LIST'
        UPDATE_STATUS_BAR_SAVE_TIME : 'UPDATE_STATUS_BAR_SAVE_TIME'

        #app/stack state
        #STARTED_APP           : 'STARTED_APP'
        #STOPPED_APP           : 'STOPPED_APP'
        #TERMINATED_APP        : 'TERMINATED_APP'
        #STACK_DELETE          : 'STACK_DELETE'
        UPDATE_APP_STATE       : 'UPDATE_APP_STATE'

        #canvas event save stack/app by ctrl+s
        CANVAS_SAVE            : 'CANVAS_SAVE'

        #navigation to dashboard - region
        NAVIGATION_TO_DASHBOARD_REGION : 'NAVIGATION_TO_DASHBOARD_REGION'

        #websocket meteor collection
        RECONNECT_WEBSOCKET            : 'RECONNECT_WEBSOCKET'
        WS_COLLECTION_READY_REQUEST    : 'WS_COLLECTION_READY_REQUEST'
        UPDATE_REQUEST_ITEM            : 'UPDATE_REQUEST_ITEM'
        UPDATE_IMPORT_ITEM             : 'UPDATE_IMPORT_ITEM'

        #quickstart data ready
        RESOURCE_QUICKSTART_READY      : 'RESOURCE_QUICKSTART_READY'

        #app ready and generate thumbnail
        SAVE_APP_THUMBNAIL     : 'SAVE_APP_THUMBNAIL'

        #update process
        UPDATE_PROCESS         : 'UPDATE_PROCESS'

        #update header
        UPDATE_HEADER          : 'UPDATE_HEADER'

        #refresh region resource
        UPDATE_REGION_RESOURCE : 'UPDATE_REGION_RESOURCE'

        #updated aws credential
        UPDATE_AWS_CREDENTIAL  : 'UPDATE_AWS_CREDENTIAL'

        #demo account
        ACCOUNT_DEMONSTRATE    : 'ACCOUNT_DEMONSTRATE'

        #update app resource and info
        UPDATE_APP_RESOURCE    : 'UPDATE_APP_RESOURCE'
        UPDATE_APP_INFO        : 'UPDATE_APP_INFO'

        UPDATE_STATE_STATUS_DATA  :  'STATE_STATUS_DATA_UPDATE'
        UPDATE_STATE_STATUS_DATA_TO_EDITOR  :  'UPDATE_STATE_STATUS_DATA_TO_EDITOR'
        STATE_EDITOR_SAVE_DATA : 'STATE_EDITOR_SAVE_DATA'

        GET_STATE_MODULE       : 'GET_STATE_MODULE'

        #state editor
        SHOW_STATE_EDITOR        : 'SHOW_STATE_EDITOR'
        STATE_EDITOR_DATA_UPDATE : 'STATE_EDITOR_DATA_UPDATE'

        onListen : ( type, callback, context ) ->
            this.once type, callback, context

        onLongListen : ( type, callback, context ) ->
            this.on type, callback, context

        offListen : ( type, function_name ) ->
            if function_name then this.off type, function_name else this.off type

    event = new Event()

    event
