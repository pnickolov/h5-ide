###

###

define [ 'underscore', 'backbone' ], () ->

    class Event

        constructor : ->
            _.extend this, Backbone.Events

        #
        OPEN_PROPERTY          : 'OPEN_PROPERTY'
        FORCE_OPEN_PROPERTY    : "FORCE_OPEN_PROPERTY"
        REFRESH_PROPERTY       : "REFRESH_PROPERTY"

        #status bar & ta
        UPDATE_STATUS_BAR      : 'UPDATE_STATUS_BAR'
        UPDATE_TA_MODAL        : 'UPDATE_TA_MODAL'
        UNLOAD_TA_MODAL        : 'UNLOAD_TA_MODAL'
        TA_SYNC_START          : 'TA_SYNC_START'
        TA_SYNC_FINISH         : 'TA_SYNC_FINISH'

        # property
        PROPERTY_REFRESH_ENI_IP_LIST : 'PROPERTY_REFRESH_ENI_IP_LIST'

        UPDATE_STATE_STATUS_DATA  :  'STATE_STATUS_DATA_UPDATE'
        UPDATE_STATE_STATUS_DATA_TO_EDITOR  :  'UPDATE_STATE_STATUS_DATA_TO_EDITOR'
        STATE_EDITOR_SAVE_DATA : 'STATE_EDITOR_SAVE_DATA'

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
