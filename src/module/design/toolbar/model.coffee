#############################
#  View Mode for design/toolbar module
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'stack_service', 'stack_model', 'app_model', 'constant' ], (MC, Backbone, $, _, ide_event, stack_service, stack_model, app_model, constant) ->

    #item state map
    # {app_id:{'name':name, 'state':state, 'is_running':true|false, 'is_pending':true|false, 'is_use_ami':true|false},
    #  stack_id:{'name':name, 'is_run':true|false, 'is_duplicate':true|false, 'is_delete':true|false}}
    item_state_map = {}
    is_tab = true

    run_stack_map = {}  # {<region>:{<app_name>:{<data>}}}

    #websocket
    ws = MC.data.websocket

    #private
    ToolbarModel = Backbone.Model.extend {

        defaults :
            'item_flags'    : null


        initialize : ->

            me = this

            #####listen STACK_SAVE_RETURN
            me.on 'STACK_SAVE_RETURN', (result) ->
                console.log 'STACK_SAVE_RETURN'

                region  = result.param[3]
                data    = result.param[4]
                id      = data.id

                name = data.name

                if !result.is_error

                    console.log 'save stack successfully'

                    # track
                    analytics.track "Saved Stack",
                        stack_name: data.name,
                        stack_region: data.region,
                        stack_id: data.id

                    #update initial data
                    MC.canvas_property.original_json = JSON.stringify( data )

                    ide_event.trigger ide_event.UPDATE_STACK_LIST, 'SAVE_STACK'

                    #call save png
                    me.savePNG true, data

                    #set toolbar flag
                    me.setFlag id, 'SAVE_STACK', name

                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'SAVE_STACK', name

                    id
                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'SAVE_STACK', name

                    null

            #####listen STACK_CREATE_RETURN
            me.on 'STACK_CREATE_RETURN', (result) ->
                console.log 'STACK_CREATE_RETURN'

                region  = result.param[3]
                data    = result.param[4]
                id      = data.id

                name    = data.name

                if !result.is_error
                    console.log 'create stack successfully'

                    # track
                    analytics.track "Saved Stack",
                        stack_name: data.name,
                        stack_region: data.region,
                        stack_id: data.id

                    new_id = result.resolved_data.id
                    key = result.resolved_data.key

                    #temp
                    MC.canvas_data.id = new_id
                    MC.canvas_data.key = key

                    #update initial data
                    MC.canvas_property.original_json = JSON.stringify( data )

                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'CREATE_STACK', name

                    ide_event.trigger ide_event.UPDATE_STACK_LIST, 'NEW_STACK'

                    ide_event.trigger ide_event.UPDATE_TABBAR, new_id, name + ' - stack'

                    MC.data.stack_list[region].push name

                    #call save png
                    me.savePNG true, data

                    #set toolbar flag
                    me.setFlag id, 'CREATE_STACK', data

                    new_id

                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'CREATE_STACK', name

                    null

            #####listen STACK_SAVE__AS_RETURN
            me.on 'STACK_SAVE__AS_RETURN', (result) ->
                console.log 'STACK_SAVE__AS_RETURN'

                region      = result.param[3]
                id          = result.param[4]
                new_name    = result.param[5]
                name        = result.param[6]

                if !result.is_error
                    console.log 'save as stack successfully'

                    #update stack name list
                    if new_name not in MC.data.stack_list[region]
                        MC.data.stack_list[region].push new_name

                    #trigger event
                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'DUPLICATE_STACK', name
                    ide_event.trigger ide_event.UPDATE_STACK_LIST
                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'DUPLICATE_STACK', name

            #####listen STACK_REMOVE_RETURN
            me.on 'STACK_REMOVE_RETURN', (result) ->
                console.log 'STACK_REMOVE_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                if !result.is_error
                    console.log 'send delete stack successful message'

                    #update stack name list
                    if name in MC.data.stack_list[region]
                        index = MC.data.stack_list[region].indexOf(name)
                        MC.data.stack_list[region].splice(index, 1)

                    #trigger event
                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'REMOVE_STACK', name
                    ide_event.trigger ide_event.STACK_DELETE, name, id

                    me.setFlag id, 'DELETE_STACK'

                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'REMOVE_STACK', name

            #####listen STACK_RUN_RETURN
            me.on 'STACK_RUN_RETURN', (result) ->
                console.log 'STACK_RUN_RETURN'

                region      = result.param[3]
                id          = result.param[4]
                app_name    = result.param[5]

                #add new-app status
                #me.handleRequest result, 'RUN_STACK', region, id, app_name
                # ide_event.trigger ide_event.OPEN_APP_PROCESS_TAB, MC.canvas_data.id, app_name, MC.canvas_data.region, result

                data = run_stack_map[region][app_name]

                ide_event.trigger ide_event.OPEN_APP_PROCESS_TAB, id, app_name, region, result

                # handle request
                me.handleRequest result, 'RUN_STACK', region, id, app_name

                # track
                analytics.track "Launched Stack",
                    stack_id: id,
                    stack_region: region,
                    stack_app_name: app_name

            #####listen APP_START_RETURN
            me.on 'APP_START_RETURN', (result) ->
                console.log 'APP_START_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                me.handleRequest result, 'START_APP', region, id, name

                # track
                analytics.track "Started App",
                    app_id: id,
                    app_region: region,
                    app_name: name

            #####listen APP_STOP_RETURN
            me.on 'APP_STOP_RETURN', (result) ->
                console.log 'APP_STOP_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                me.handleRequest result, 'STOP_APP', region, id, name

                # track
                analytics.track "Stopped App",
                    app_id: id,
                    app_region: region,
                    app_name: name

            #####listen APP_TERMINATE_RETURN
            me.on 'APP_TERMINATE_RETURN', (result) ->
                console.log 'APP_TERMINATE_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                me.handleRequest result, 'TERMINATE_APP', region, id, name

                # track
                analytics.track "Terminated App",
                    app_id: id,
                    app_region: region,
                    app_name: name

            #####listen APP_GETKEY_RETURN
            me.on 'APP_GETKEY_RETURN', (result) ->
                console.log 'APP_GETKEY_RETURN'

                if !result.is_error
                    # trigger toolbar save png event
                    console.log 'app key:' + result.resolved_data

                    data.key = result.resolved_data

                    me.savePNG true, data


        setFlag : (id, flag, value) ->
            me = this

            if flag is 'NEW_STACK'
                item_state_map[id] = {'name':MC.canvas_data.name, 'is_run':true, 'is_duplicate':false, 'is_delete':false}
                is_tab = true

            else if flag is 'OPEN_STACK'
                id = id.resolved_data[0].id
                item_state_map[id] = {'name':MC.canvas_data.name, 'is_run':true, 'is_duplicate':true, 'is_delete':true}
                is_tab = true

            else if flag is 'SAVE_STACK'
                item_state_map[id] = {'name':value, 'is_run':true, 'is_duplicate':true, 'is_delete':true}

            else if flag is 'CREATE_STACK'
                delete item_state_map[id]
                item_state_map[value.id] = {'name':value.name, 'is_run':true, 'is_duplicate':true, 'is_delete':true}

                id = value.id

            else if flag is 'DELETE_STACK'
                delete item_state_map[id]
                return

            else if flag is 'OPEN_APP'
                is_running = false
                is_pending = false

                if MC.canvas_data.state == constant.APP_STATE.APP_STATE_STOPPED
                    is_running = false
                else if MC.canvas_data.state == constant.APP_STATE.APP_STATE_RUNNING
                    is_running = true
                else
                    is_running = false
                    is_pending = true

                id = id.resolved_data[0].id
                item_state_map[id] = { 'name':MC.canvas_data.name, 'state':MC.canvas_data.state, 'is_running':is_running, 'is_pending':is_pending, 'is_use_ami':me.isInstanceStore(MC.canvas_data) }

                is_tab = true

            else if flag is 'RUNNING_APP'
                if id of item_state_map
                    item_state_map[id].state = constant.APP_STATE.APP_STATE_RUNNING
                    item_state_map[id].is_running = true
                    item_state_map[id].is_pending = false

                ide_event.trigger ide_event.UPDATE_TAB_ICON, 'running', id

            else if flag is 'STOPPED_APP'
                if id of item_state_map
                    item_state_map[id].state = constant.APP_STATE.APP_STATE_STOPPED
                    item_state_map[id].is_running = false
                    item_state_map[id].is_pending = false

                ide_event.trigger ide_event.UPDATE_TAB_ICON, 'stopped', id

            else if flag is 'TERMINATED_APP'
                (delete item_state_map[id]) if id of item_state_map
                return

            else if flag is 'PENDING_APP'
                if id of item_state_map
                    item_state_map[id].is_pending = true

                ide_event.trigger ide_event.UPDATE_TAB_ICON, 'pending', id

            if id == MC.canvas_data.id and is_tab
                me.set 'item_flags', item_state_map[id]

                if id.indexOf('app-') == 0
                    me.trigger 'UPDATE_TOOLBAR', 'app'
                else
                    me.trigger 'UPDATE_TOOLBAR', 'stack'

        setTabFlag : (flag) ->
            me = this

            is_tab = flag

            if flag
                id = MC.canvas_data.id

                rid = k for k,v of item_state_map when id == k

                if rid
                    me.set 'item_flags', item_state_map[id]

                    if id.indexOf('app-') == 0
                        me.trigger 'UPDATE_TOOLBAR', 'app'
                    else
                        me.trigger 'UPDATE_TOOLBAR', 'stack'

            null

        #save stack
        saveStack : (data) ->
            me = this

            region = data.region
            id = data.id
            name = data.name

            data.has_instance_store_ami = me.isInstanceStore data
            if id.indexOf('stack-', 0) == 0   #save
                stack_model.save { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, data

            else    #new
                stack_model.create { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, data

        #duplicate
        duplicateStack : (new_name, data) ->
            me = this

            region = data.region
            id = data.id
            name = data.name
            if me.isChanged(data)
                if not me.saveStack(data)
                   return

            stack_model.save_as { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, new_name, name

        #delete
        deleteStack : (data) ->
            me = this

            region = data.region
            id = data.id
            name = data.name

            stack_model.remove { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

        #run
        runStack : ( app_name, data) ->
            me = this

            id = data.id
            region = data.region
            if me.isChanged(data) or id.indexOf('stack-') isnt 0
                me.saveStack(data)
                id = MC.canvas_data.id
                if not id
                    return

            #src, username, session_id, region_name, stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null
            stack_model.run { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, app_name

            # stack_service.run { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, app_name, null, null, null, null, null, ( result ) ->

            #     if !result.is_error
            #     #run succeed

            #         console.log 'STACK_RUN_RETURN'

            #         region      = result.param[3]
            #         id          = result.param[4]
            #         app_name    = result.param[5]

            #         #add new-app status
            #         #me.handleRequest result, 'RUN_STACK', region, id, app_name
            #         # ide_event.trigger ide_event.OPEN_APP_PROCESS_TAB, MC.canvas_data.id, app_name, MC.canvas_data.region, result
            #         # # track
            #         # analytics.track "Launched Stack",
            #         #     stack_id: id,
            #         #     stack_region: region,
            #         #     stack_app_name: app_name
            #         #ide_event.trigger ide_event.OPEN_APP_PROCESS_TAB, id, app_name, region, result


            #     else
            #     #run failed

            #         console.log 'stack.run failed, error is ' + result.error_message



            # save stack data
            if not (region of run_stack_map) then run_stack_map[region] = {}

            run_stack_map[region][app_name] = data

            null


        savePNG : ( is_thumbnail, data ) ->
            console.log 'savePNG'
            me = this
            #
            callback = ( result ) ->
                console.log 'phantom callback'
                console.log result.data.host
                return if result.data.host isnt MC.SAVEPNG_URL.replace( 'http://', '' ).replace( '/', '' )
                if result.data.res.status is 'success'
                    if result.data.res.thumbnail is 'true'
                        console.log 's3 url = ' + result.data.res.result
                        window.removeEventListener 'message', callback

                        #push event
                        ide_event.trigger ide_event.UPDATE_REGION_THUMBNAIL, result.data.res.result
                    else
                        me.trigger 'SAVE_PNG_COMPLETE', result.data.res.result
                        window.removeEventListener 'message', callback
                else
                    #window.removeEventListener 'message', callback
            window.addEventListener 'message', callback
            #
            phantom_data =
                'origin_host': window.location.origin,
                'usercode'   : $.cookie( 'usercode'   ),
                'session_id' : $.cookie( 'session_id' ),
                'thumbnail'  : is_thumbnail,
                'json_data'  : JSON.stringify(data),
                'stack_id'   : data.id
                'url'        : data.key
            #
            sendMessage = ->
                $( '#phantom-frame' )[0].contentWindow.postMessage phantom_data, MC.SAVEPNG_URL
            if $( '#phantom-frame' )[0] is undefined
                $( document.body ).append '<iframe id="phantom-frame" src="' + MC.SAVEPNG_URL + 'proxy.html" style="display:none;"></iframe>'
                $('#phantom-frame').load -> sendMessage()
            else
                sendMessage()
            #
            if is_thumbnail is 'true' then me.trigger 'SAVE_PNG_COMPLETE', null
            null
            ###
            me = this
            $.ajax {
                url  : MC.SAVEPNG_URL,
                type : 'post',
                data : {
                    'usercode'   : $.cookie( 'usercode'   ),
                    'session_id' : $.cookie( 'session_id' ),
                    'thumbnail'  : is_thumbnail,
                    'json_data'  : MC.canvas.layout.save(),
                    'stack_id'   : id
                },
                success : ( res ) ->
                    console.log 'phantom callback'
                    console.log res
                    console.log res.status
                    if res.status is 'success'
                        if res.thumbnail is 'true'
                            console.log 's3 url = ' + res.result
                            ide_event.trigger ide_event.UPDATE_STACK_THUMBNAIL
                        else
                            me.trigger 'SAVE_PNG_COMPLETE', res.result
                    else
                        #
            }
            ###

        isChanged : (data) ->
            #check if there are changes
            ori_data = MC.canvas_property.original_json
            new_data = JSON.stringify( data )

            if ori_data != new_data
                return true
            else
                return false

        startApp : (region, id, name) ->
            me = this

            app_model.start { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

        stopApp : (region, id, name) ->
            me = this

            app_model.stop { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

        terminateApp : (region, id, name) ->
            me = this

            #terminate : ( src, username, session_id, region_name, app_id, app_name=null )
            app_model.terminate { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

        handleRequest : (result, flag, region, id, name) ->
            me = this

            if flag isnt 'RUN_STACK'
                me.setFlag id, 'PENDING_APP'

            if !result.is_error
                # if flag is 'RUN_STACK'
                #     console.log 'run stack request successfully'
                #     me.trigger 'TOOLBAR_STACK_RUN_REQUEST_SUCCESS', name

                # else if flag is 'START_APP'
                #     console.log 'start app request successfully'
                #     me.trigger 'TOOLBAR_APP_START_REQUEST_SUCCESS', name

                # else if flag is 'STOP_APP'
                #     console.log 'stop app request successfully'
                #     me.trigger 'TOOLBAR_APP_STOP_REQUEST_SUCCESS', name

                # else if flag is 'TERMINATE_APP'
                #     console.log 'terminate app request successfully'
                #     me.trigger 'TOOLBAR_APP_TERMINATE_SUCCESS', name

                me.trigger 'TOOLBAR_REQUEST_SUCCESS', flag, name

                if ws
                    req_id = result.resolved_data.id
                    console.log 'request id:' + req_id
                    query = ws.collection.request.find({id:req_id})
                    handle = query.observeChanges {
                        added   : (idx, dag) ->
                            req_list = MC.data.websocket.collection.request.find({'_id' : idx}).fetch()
                            req = req_list[0]

                            console.log 'added request ' + req.data + "," + req.state

                            me.reqHanle flag, id, name, req, dag

                        changed : (idx, dag) ->
                            req_list = MC.data.websocket.collection.request.find({'_id' : idx}).fetch()
                            req = req_list[0]

                            console.log 'changed request ' + req.data + "," + req.state

                            me.reqHanle flag, id, name, req, dag

                            if req.state is constant.OPS_STATE.OPS_STATE_FAILED or req.state is constant.OPS_STATE.OPS_STATE_DONE
                                handle.stop()

                    }

                    null

            else
                # if flag == 'START_APP'
                #     me.trigger 'TOOLBAR_APP_START_REQUEST_FAILED', name
                #     #MC.canvas_data.state = 'Stopped'
                # else if flag == 'STOP_APP'
                #     me.trigger 'TOOLBAR_APP_STOP_REQUEST_FAILED', name
                #     #MC.canvas_data.state = 'Running'
                # else if flag == 'TERMINATE_APP'
                #     me.trigger 'TOOLBAR_APP_TERMINATE_REQUEST_FAILED', name
                #     #MC.canvas_data.state = 'Stopped'

                me.trigger 'TOOLBAR_REQUEST_FAILED', flag, name

                if flag isnt 'RUN_STACK'
                    me.setFlag id, 'STOPPED_APP'

        reqHanle : (flag, id, name, req, dag) ->
            me = this

            # update header
            ide_event.trigger ide_event.UPDATE_HEADER, req

            flag_list = {}

            region = req.region

            switch req.state
                when constant.OPS_STATE.OPS_STATE_INPROCESS
                    if flag is 'RUN_STACK'

                        if 'dag' of dag # changed request
                            flag_list.is_inprocess = true
                            flag_list.steps = dag.dag.step.length

                            # check rollback
                            dones = 0
                            dones++ for step in dag.dag.step when step[1].toLowerCase() is 'done'
                            console.log 'done steps:' + dones
                            if dag.dag.state isnt 'Rollback'
                                flag_list.dones = dones
                                flag_list.rate = Math.round(flag_list.dones*100/flag_list.steps)

                        else # added request
                            flag_list.is_pending = true

                when constant.OPS_STATE.OPS_STATE_FAILED
                    #handle.stop()

                    me.trigger 'TOOLBAR_HANDLE_FAILED', flag, name

                    if flag is 'RUN_STACK'
                        flag_list.is_failed = true
                        flag_list.err_detail = req.data
                    else
                        me.setFlag id, 'STOPPED_APP'

                when constant.OPS_STATE.OPS_STATE_DONE
                    #handle.stop()

                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', flag, name

                    lst = req.data.split(' ')
                    app_id = lst[lst.length-1]

                    switch flag
                        when 'RUN_STACK'
                            flag_list.app_id = app_id
                            flag_list.is_done = true

                        when 'START_APP'
                            me.setFlag id, 'RUNNING_APP'
                            ide_event.trigger ide_event.STARTED_APP, name, id

                        when 'STOP_APP'
                            me.setFlag id, 'STOPPED_APP'
                            ide_event.trigger ide_event.STOPPED_APP, name, id

                        when 'TERMINATE_APP'
                            me.setFlag id, 'TERMINATED_APP'
                            ide_event.trigger ide_event.TERMINATED_APP, name, id

                            # remove the app name from app_list
                            if name in MC.data.app_list[region]
                                MC.data.app_list[region].splice MC.data.app_list[region].indexOf(name), 1

                        else
                            console.log 'not support toolbar operation:' + flag

                else
                    console.log 'not support request state:' + req.state

            # send process data
            if flag_list and flag is 'RUN_STACK'

                tab_name = 'process-' + region + '-' + name

                MC.process[tab_name].flag_list = flag_list

                ide_event.trigger ide_event.UPDATE_PROCESS, tab_name

        isInstanceStore : ( data ) ->

            is_instance_store = false

            if 'component' in data.layout and 'node' in data.layout.component
                for node in data.layout.component.node
                    if node.rootDeviceType == 'instance-store'
                        is_instance_store = true
                        break

            is_instance_store

        saveAppThumbnail  :   ( region, app_name, app_id ) ->
            me = this

            data = run_stack_map[region][app_name]

            if data
                # generate s3 key
                app_model.getKey { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, app_id
                app_model.once 'APP_GETKEY_RETURN', (result) ->
                    console.log 'APP_GETKEY_RETURN'
                    console.log result

                    if !result.is_error
                        # trigger toolbar save png event
                        console.log 'app key:' + result.resolved_data

                        data.key = result.resolved_data

                        me.savePNG true, data

            null

    }

    model = new ToolbarModel()

    return model
