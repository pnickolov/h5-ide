#############################
#  View Mode for header module
#############################

define [ 'event', 'backbone', 'jquery', 'underscore', 'constant' ], ( ide_event, Backbone, $, _, constant ) ->

    #websocket
    #ws = MC.data.websocket

    ProcessModel = Backbone.Model.extend {

        defaults:
            'flag_list'         : null  #flag_list = {'is_pending':true|false, 'is_inprocess':true|false, 'is_done':true|false, 'is_failed':true|false, 'steps':0, 'dones':0, 'rate':0}

        initialize  : ->
            me = this

            me.set 'flag_list', {'is_pending':true}

        getProcess  : (tab_name) ->
            me = this

            if MC.process[tab_name]
                # get the data
                flag_list = MC.process[tab_name].flag_list

                # linear increase

                me.set 'flag_list', flag_list

                # push event when done
                app_name = MC.process[tab_name].app_name
                if 'is_done' of flag_list and flag_list.is_done     # completed
                    app_id = flag_list.app_id
                    region = MC.process[tab_name].region

                    # save png
                    ide_event.trigger ide_event.SAVE_APP_THUMBNAIL, region, app_name, app_id

                    # hold on two seconds
                    setTimeout () ->
                        ide_event.trigger ide_event.UPDATE_TABBAR, app_id, app_name + ' - app'
                        ide_event.trigger ide_event.PROCESS_RUN_SUCCESS, app_id, region
                        ide_event.trigger ide_event.DELETE_TAB_DATA, tab_name
                        ide_event.trigger ide_event.UPDATE_APP_LIST, null
                    , 2000

                else # in progress

                    $('#progress_bar').css('width',Math.round( flag_list.rate,0 ) + "%" )

            null

    }

    model = new ProcessModel()
    return model
