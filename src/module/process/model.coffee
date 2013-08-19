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

                me.set 'flag_list', flag_list

                # push event when done
                app_name = MC.process[tab_name].app_name
                #if MC.data.current_tab_id is 'process-' + app_name and 'is_done' of flag_list and flag_list.is_done
                if 'is_done' of flag_list and flag_list.is_done
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

                # if type is 'OPEN_PROCESS'
                #     #initial the start state
                #     flag_list = {'is_pending':true}
                #     me.set 'flag_list', flag_list
                #     MC.process[tab_name].flag_list = flag_list

                #     me.trigger 'UPDATE_PROCESS'

                #     me.handleProcess tab_name

                # else if type is 'OLD_PROCESS'
                #     if MC.process[tab_name].flag_list   # processing app
                #         me.set 'flag_list', MC.process[tab_name].flag_list
                #         me.trigger 'UPDATE_PROCESS'

                #         # if ended then push event
                #         app_name = MC.process[tab_name].app_name
                #         app_id = MC.process[tab_name].flag_list.app_id
                #         region = MC.process[tab_name].data.region
                #         #data = MC.process[tab_name].data
                #         if MC.data.current_tab_id is 'process-'+app_name and MC.process[tab_name].flag_list.is_done
                #             #save png
                #             data = $.extend( true, {}, MC.process[tab_name].data )
                #             data.id = app_id
                #             ide_event.trigger ide_event.SAVE_APP_THUMBNAIL, data

                #             # hold on 2 seconds
                #             setTimeout () ->
                #                 ide_event.trigger ide_event.UPDATE_TABBAR, app_id, app_name + ' - app'
                #                 ide_event.trigger ide_event.PROCESS_RUN_SUCCESS, app_id, region
                #                 ide_event.trigger ide_event.DELETE_TAB_DATA, tab_name
                #                 ide_event.trigger ide_event.UPDATE_APP_LIST, null
                #             , 2000

            null

        # handleProcess : (tab_name) ->
        #     me = this

        #     #process = MC.process[tab_name]
        #     process  = $.extend( true, {}, MC.process[tab_name] )
        #     app_name = process.app_name

        #     console.log 'handleProcess id:' + process.tab_id

        #     if !process.result.is_error

        #         if ws
        #             req_id = process.result.resolved_data.id
        #             console.log 'request id:' + req_id
        #             query = ws.collection.request.find({id:req_id})
        #             handle = query.observeChanges {
        #                 changed : (idx, dag) =>
        #                     flag_list = {}

        #                     req_list = MC.data.websocket.collection.request.find({'_id' : idx}).fetch()
        #                     req = req_list[0]

        #                     console.log 'request ' + req.data + "," + req.state + ',' + dag.dag.state

        #                     #app_name = req.brief.split(' ')[2]

        #                     if req.state is constant.OPS_STATE.OPS_STATE_INPROCESS
        #                         flag_list.is_inprocess = true

        #                         flag_list.steps = dag.dag.step.length

        #                         # check rollback
        #                         dones = 0
        #                         dones++ for step in dag.dag.step when step[1].toLowerCase() is 'done'
        #                         console.log 'done steps:' + dones
        #                         if dag.dag.state is 'Rollback'
        #                             tmp_list = me.get 'flag_list'
        #                             if tmp_list.dones>0 then (dones = tmp_list.dones) else (dones = 0)

        #                         flag_list.dones = dones
        #                         flag_list.rate = Math.round(flag_list.dones*100/flag_list.steps)

        #                     else if req.state is constant.OPS_STATE.OPS_STATE_DONE
        #                         handle.stop()

        #                         lst = req.data.split(' ')
        #                         app_id = lst[lst.length-1]

        #                         flag_list.app_id = app_id
        #                         flag_list.is_done = true

        #                         # if on current tab
        #                         if MC.data.current_tab_id is 'process-' + app_name
        #                             # save png
        #                             process.data.id = app_id
        #                             ide_event.trigger ide_event.SAVE_APP_THUMBNAIL, process.data

        #                             # hold on 2 seconds
        #                             setTimeout () ->
        #                                 ide_event.trigger ide_event.UPDATE_TABBAR, app_id, app_name + ' - app'
        #                                 ide_event.trigger ide_event.PROCESS_RUN_SUCCESS, app_id, req.region
        #                                 ide_event.trigger ide_event.DELETE_TAB_DATA, 'process-' + app_name
        #                                 ide_event.trigger ide_event.UPDATE_APP_LIST, null
        #                             , 2000

        #                     else if req.state is constant.OPS_STATE.OPS_STATE_FAILED
        #                         handle.stop()

        #                         flag_list.is_failed = true
        #                         flag_list.err_detail = req.data

        #                         if app_name in MC.data.app_list[process.data.region]
        #                             MC.data.app_list[process.data.region].splice MC.data.app_list[process.data.region].indexOf(app_name), 1

        #                         if MC.data.current_tab_id is tab_name
        #                             # update tab icon
        #                             ide_event.trigger ide_event.UPDATE_TAB_ICON, 'stopped', tab_name


        #                     MC.process[tab_name].flag_list = flag_list

        #                     if MC.data.current_tab_id is 'process-'+app_name   # current tab
        #                         console.log 'current prcess tab:' + MC.data.current_tab_id

        #                         me.set 'flag_list', flag_list
        #                         me.trigger 'UPDATE_PROCESS'

        #             }

        #             null

        #     else
        #         console.log 'process request failed'

        #         flag_list = {}
        #         flag_list.is_failed = true

        #         MC.process[tab_name].flag_list = flag_list

        #         if MC.data.current_tab_id is tab_name
        #             me.set 'flag_list', flag_list
        #             me.trigger 'UPDATE_PROCESS'

        #             # update tab icon
        #             ide_event.trigger ide_event.UPDATE_TAB_ICON, 'stopped', tab_name

        #         if app_name in MC.data.app_list[process.data.region]
        #             MC.data.app_list[process.data.region].splice MC.data.app_list[process.data.region].indexOf(app_name), 1


    }

    model = new ProcessModel()
    return model
