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

                last_flag = me.get 'flag_list', flag_list

                if 'is_done' of flag_list and flag_list.is_done     # completed

                    # complete the progress
                    $('#progress_bar').css('width', "100%" )
                    $('#progress_num').text last_flag.steps
                    $('#progress_total').text last_flag.steps

                    # hold on 1 second
                    setTimeout () ->
                        me.set 'flag_list', flag_list

                        app_id = flag_list.app_id
                        region = MC.process[tab_name].region

                        # save png
                        app_name = MC.process[tab_name].app_name
                        ide_event.trigger ide_event.SAVE_APP_THUMBNAIL, region, app_name, app_id

                        # hold on two seconds
                        setTimeout () ->
                            ide_event.trigger ide_event.UPDATE_TABBAR, app_id, app_name + ' - app'
                            ide_event.trigger ide_event.PROCESS_RUN_SUCCESS, app_id, region
                            ide_event.trigger ide_event.DELETE_TAB_DATA, tab_name
                            ide_event.trigger ide_event.UPDATE_APP_LIST, null
                        , 2000
                    , 1000

                else if 'is_inprocess' of flag_list and flag_list.is_inprocess # in progress

                    # first go into inprogress
                    if 'is_pending' of last_flag and last_flag.is_pending

                        last_flag.is_pending = false
                        last_flag.is_inprocess = true

                        # push event
                        me.set 'flag_list', last_flag

                        # hold on 1 second
                        # setTimeout () ->
                        #     console.log 'Update the header'
                        # , 500

                    me.set 'flag_list', flag_list

                    if 'dones' of flag_list #and flag_list.dones > 0 and 'steps' of flag_list and flag_list.steps > 0

                        if flag_list.dones > 0 and 'steps' of flag_list and flag_list.steps > 0
                            $('#progress_bar').css('width', Math.round( flag_list.dones/flag_list.steps*100 ) + "%" )
                            $('#progress_num').text flag_list.dones
                            $('#progress_total').text flag_list.steps
                        
                        else
                            $('#progress_bar').css('width', "0" )
                            $('#progress_num').text '0'
                            $('#progress_total').text '0'

                else

                    me.set 'flag_list', flag_list

            null


    }

    model = new ProcessModel()
    return model
