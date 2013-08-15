#############################
#  View Mode for header module
#############################

define [ 'event', 'backbone', 'jquery', 'underscore', 'constant', 'app_model' ], ( ide_event, Backbone, $, _, constant, app_model ) ->

    #websocket
    ws = MC.data.websocket

    ProcessModel = Backbone.Model.extend {

        defaults:
            'flag_list'         : null  #flag_list = {'is_pending':true|false, 'is_inprocess':true|false, 'is_done':true|false, 'is_failed':true|false, 'steps':0, 'dones':0, 'rate':0}

        initialize  : ->
            me = this

            me.set 'flag_list', {'is_pending':true}

        getProcess  : (type, tab_name) ->
            me = this

            console.log 'tab type is:' + type

            if MC.data.current_tab_id.split('-')[0] isnt 'process'
                return

            console.log 'getProcess tab name:' + tab_name

            if MC.process[tab_name]
                if type is 'OPEN_PROCESS'
                    #initial the start state
                    flag_list = {'is_pending':true}
                    me.set 'flag_list', flag_list
                    MC.process[tab_name].flag_list = flag_list

                    me.trigger 'UPDATE_PROCESS'

                    me.handleProcess tab_name

                else if type is 'OLD_PROCESS'
                    if MC.process[tab_name].flag_list   # processing app
                        me.set 'flag_list', MC.process[tab_name].flag_list
                        me.trigger 'UPDATE_PROCESS'

                        # if ended then push event
                        app_name = MC.process[tab_name].app_name
                        app_id = MC.process[tab_name].flag_list.app_id
                        region = MC.process[tab_name].data.region
                        if MC.data.current_tab_id is 'process-'+app_name and MC.process[tab_name].flag_list.is_done
                            # hold on 2 seconds
                            setTimeout () ->
                                ide_event.trigger ide_event.UPDATE_TABBAR, app_id, app_name + ' - app'
                                ide_event.trigger ide_event.PROCESS_RUN_SUCCESS, app_id, region
                                ide_event.trigger ide_event.DELETE_TAB_DATA, tab_name
                            , 2000



            null

        handleProcess : (tab_name) ->
            me = this

            process = MC.process[tab_name]

            console.log 'handleProcess id:' + process.tab_id

            if !process.result.is_error

                if ws
                    req_id = process.result.resolved_data.id
                    console.log 'request id:' + req_id
                    query = ws.collection.request.find({id:req_id})
                    handle = query.observeChanges {
                        changed : (idx, dag) ->
                            flag_list = {}

                            req_list = MC.data.websocket.collection.request.find({'_id' : idx}).fetch()
                            req = req_list[0]

                            console.log 'request ' + req.data + "," + req.state + ',' + dag.dag.state

                            app_name = req.brief.split(' ')[2]

                            if req.state is constant.OPS_STATE.OPS_STATE_INPROCESS
                                flag_list.is_inprocess = true
                                flag_list.steps = dag.dag.step.length

                                dones = 0
                                dones++ for step in dag.dag.step when step[1].toLowerCase() is 'done'
                                flag_list.dones = dones
                                flag_list.rate = Math.round(flag_list.dones*100/flag_list.steps)

                            else if req.state is constant.OPS_STATE.OPS_STATE_DONE
                                handle.stop()

                                lst = req.data.split(' ')
                                app_id = lst[lst.length-1]

                                flag_list.app_id = app_id
                                flag_list.is_done = true

                                # if on current tab
                                if MC.data.current_tab_id is 'process-' + app_name
                                    # hold on 2 seconds
                                    setTimeout () ->
                                        ide_event.trigger ide_event.UPDATE_TABBAR, app_id, app_name + ' - app'
                                        ide_event.trigger ide_event.PROCESS_RUN_SUCCESS, app_id, req.region
                                        ide_event.trigger ide_event.DELETE_TAB_DATA, 'process-' + app_name
                                    , 2000

                            else if req.state is constant.OPS_STATE.OPS_STATE_FAILED
                                handle.stop()

                                flag_list.is_failed = true
                                flag_list.err_detail = req.data


                            MC.process[tab_name].flag_list = flag_list

                            if MC.data.current_tab_id is 'process-'+app_name   # current tab
                                console.log 'current prcess tab:' + MC.data.current_tab_id

                                me.set 'flag_list', flag_list
                                me.trigger 'UPDATE_PROCESS'

                    }

                    null

            else
                console.log 'process request failed'

                flag_list = {}
                flag_list.is_failed = true

                MC.process[tab_name].flag_list = flag_list

                if MC.data.current_tab_id is tab_name
                    me.set 'flag_list', flag_list
                    me.trigger 'UPDATE_PROCESS'

        getKey  :   (region, app_id) ->
            me = this

            # generate s3 key
            app_model.getKey { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, app_id
            app_model.once 'APP_GETKEY_RETURN', (result) ->
                console.log 'APP_GETKEY_RETURN'
                console.log result

                if !result.is_error
                    # trigger toolbar save png event
                    console.log 'TOOLBAR_SAVE_PNG'
                    # data.key = result.resolved_data

            null

    }

    model = new ProcessModel()
    return model
