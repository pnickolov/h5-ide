#############################
#  View Mode for header module
#############################

define [ 'event', 'backbone', 'jquery', 'underscore', 'constant' ], ( ide_event, Backbone, $, _, constant ) ->

    #websocket
    ws = MC.data.websocket

    ProcessModel = Backbone.Model.extend {

        defaults:
            'flag_list'         : null  #flag_list = {'is_pending':true|false, 'is_inprocess':true|false, 'is_done':true|false, 'is_failed':true|false, 'steps':0, 'dones':0, 'rate':0}

        initialize  : ->
            me = this

            me.set 'flag_list', {'is_pending':true}

        getProcess  : (tab_name) ->
            me = this

            console.log 'getProcess tab name:' + tab_name

            if MC.process[tab_name]
                me.handleProcess MC.process[tab_name]

            null

        handleProcess : (process) ->
            me = this

            console.log 'handleProcess id:' + process.tab_id

            flag_list = {}

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

                            if req.state is constant.OPS_STATE.OPS_STATE_INPROCESS
                                flag_list.is_inprocess = true
                                flag_list.steps = dag.dag.step.length

                                dones = 0
                                dones++ for step in dag.dag.step when step[1].toLowerCase() is 'done'
                                flag_list.dones = dones
                                flag_list.rate = Math.round(flag_list.dones*100/flag_list.steps)

                            else if req.state is constant.OPS_STATE.OPS_STATE_DONE
                                handle.stop()

                                flag_list.is_done = true

                            else if req.state is constant.OPS_STATE.OPS_STATE_FAILED
                                handle.stop()

                                flag_list.is_failed = true
                                flag_list.err_detail = req.data

                            me.set 'flag_list', flag_list
                            me.trigger 'UPDATE_PROCESS'

                    }

                    null

            else
                console.log 'process request failed'

                flag_list.is_failed = true
                me.set 'flag_list', flag_list
                me.trigger 'UPDATE_PROCESS'

    }

    model = new ProcessModel()
    return model
