#############################
#  View Mode for design/toolbar module
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'stack_model', 'app_model', 'constant' ], (MC, Backbone, $, _, ide_event, stack_model, app_model, constant) ->

    #websocket
    ws = MC.data.websocket

    #private
    ToolbarModel = Backbone.Model.extend {

        defaults :
            'toolbar_flag'  : null
            'item_name'     : null
            'item_type'     : null
            'is_running'    : null
            'is_pending'    : null
            'is_use_ami'    : null

        setFlag : (type, value) ->
            me = this

            #set stack name
            if MC.canvas_data.name
                me.set 'item_name', MC.canvas_data.name

            toolbar_flag_list = me.get 'toolbar_flag'
            if not toolbar_flag_list
                toolbar_flag_list = { 'run' : false, 'save' : false, 'duplicate' : false, 'delete' : false, 'zoomin' : true, 'zoomout' : true, 'start' : false, 'stop' : false, 'terminate' : true }

            if type is 'NEW_STACK'
                me.set 'item_type', 'stack'
                toolbar_flag_list.duplicate  = false
                toolbar_flag_list.delete     = false
            else if type is 'OPEN_STACK'
                me.set 'item_type', 'stack'
                toolbar_flag_list.duplicate  = true
                toolbar_flag_list.delete     = true
            else if type is 'SAVE_STACK'
                toolbar_flag_list.duplicate  = true
                toolbar_flag_list.delete     = true
            else if type is 'ZOOM_IN'
                toolbar_flag_list.zoomin     = value
            else if type is 'ZOOM_OUT'
                toolbar_flag_list.zoomout    = value
            else if type is 'OPEN_APP'
                me.set 'item_type', 'app'
                
                if MC.canvas_data.state == 'Stopped'
                    me.set 'is_running', false
                else if MC.canvas_data.state == 'Running'
                    me.set 'is_running', true

                me.set 'is_use_ami', me.isInstanceStore()

                toolbar_flag_list.start = true
            else if type is 'START_APP'
                toolbar_flag_list.start = false
                toolbar_flag_list.stop = true
            else if type is 'STOP_APP'
                toolbar_flag_list.start = true
                toolbar_flag_list.stop = false

            me.set 'toolbar_flag', toolbar_flag_list
            me.trigger 'UPDATE_TOOLBAR', me.get 'item_type'

        #save stack
        saveStack : () ->
            me = this

            id = MC.canvas_data.id
            if id   #save
                stack_model.save { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data

                stack_model.once 'STACK_SAVE_RETURN', (result) ->
                    console.log 'STACK_SAVE_RETURN'
                    console.log result

                    if !result.is_error
                        console.log 'save stack successfully'

                        #update initial data
                        MC.canvas_property.original_json = JSON.stringify( MC.canvas_data )

                        me.trigger 'TOOLBAR_STACK_SAVE_SUCCESS'

                        ide_event.trigger ide_event.UPDATE_STACK_LIST

                        #call save png
                        me.savePNG true

                        #set toolbar flag
                        me.setFlag 'SAVE_STACK'
                    else
                        me.trigger 'TOOLBAR_STACK_SAVE_FAILED'

            else    #new
                stack_model.create { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data

                stack_model.once 'STACK_CREATE_RETURN', (result) ->
                    console.log 'STACK_CREATE_RETURN'
                    console.log result

                    if !result.is_error
                        console.log 'create stack successfully'

                        MC.canvas_data.id = result.resolved_data

                        #update initial data
                        MC.canvas_property.original_json = JSON.stringify( MC.canvas_data )

                        me.trigger 'TOOLBAR_STACK_SAVE_SUCCESS'

                        ide_event.trigger ide_event.UPDATE_STACK_LIST

                        ide_event.trigger ide_event.UPDATE_TABBAR, MC.canvas_data.id, MC.canvas_data.name + ' - stack'

                        MC.data.stack_list[MC.canvas_data.region].push MC.canvas_data.name

                        #call save png
                        me.savePNG true

                        #set toolbar flag
                        me.setFlag 'SAVE_STACK'

                    else
                        me.trigger 'TOOLBAR_STACK_SAVE_FAILED'

        #duplicate
        duplicateStack : (new_name) ->
            me = this

            if not MC.canvas_data.id or me.isChanged()
                me.saveStack()

            stack_model.save_as { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, new_name, MC.canvas_data.name
            stack_model.once 'STACK_SAVE__AS_RETURN', (result) ->
                console.log 'STACK_SAVE__AS_RETURN'
                console.log result

                if !result.is_error
                    console.log 'save as stack successfully'

                    #update stack name list
                    if new_name not in MC.data.stack_list[MC.canvas_data.region]
                        MC.data.stack_list[MC.canvas_data.region].push new_name

                    #trigger event
                    me.trigger 'TOOLBAR_STACK_DUPLICATE_SUCCESS'
                    ide_event.trigger ide_event.UPDATE_STACK_LIST
                else
                    me.trigger 'TOOLBAR_STACK_DUPLICATE_FAILED'

        #delete
        deleteStack : () ->
            me = this

            stack_model.remove { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
            stack_model.once 'STACK_REMOVE_RETURN', (result) ->
                console.log 'STACK_REMOVE_RETURN'
                console.log result

                if !result.is_error
                    console.log 'send delete stack successful message'

                    #update stack name list
                    if MC.canvas_data.name in MC.data.stack_list[MC.canvas_data.region]
                        index = MC.data.stack_list[MC.canvas_data.region].indexOf(MC.canvas_data.name)
                        MC.data.stack_list[MC.canvas_data.region].splice(index, 1)

                    #trigger event
                    me.trigger 'TOOLBAR_STACK_DELETE_SUCCESS'
                    ide_event.trigger ide_event.STACK_DELETE, MC.canvas_data.name, MC.canvas_data.id

                else
                    me.trigger 'TOOLBAR_STACK_DELETE_FAILED'

        #run
        runStack : ( app_name ) ->
            me = this

            if not MC.canvas_data.id or me.isChanged
                me.saveStack()

            #src, username, session_id, region_name, stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null
            stack_model.run { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, app_name
            stack_model.once 'STACK_RUN_RETURN', (result) ->
                console.log 'STACK_RUN_RETURN'
                console.log result

                me.set 'is_pending', true
                me.handleRequest result, 'RUN_STACK'

        #zoomin
        zoomIn : () ->
            me = this

            MC.canvas.zoomIn()

            zoomin_flag = true
            if MC.canvas_property.SCALE_RATIO <= 1
                zoomin_flag = false

            me.setFlag('ZOOM_IN', zoomin_flag)

            null

        #zoomout
        zoomOut : () ->
            me = this

            MC.canvas.zoomOut()

            zoomout_flag = true
            if MC.canvas_property.SCALE_RATIO >= 1.8
                zoomout_flag = false

            me.setFlag('ZOOM_OUT', zoomout_flag)

            null

        savePNG : ( is_thumbnail ) ->
            console.log 'savePNG'
            me = this
            #
            $.ajax {
                url  : 'http://localhost:3001/savepng',
                type : 'post',
                data : {
                    'usercode'   : $.cookie( 'usercode'   ),
                    'session_id' : $.cookie( 'session_id' ),
                    'thumbnail'  : is_thumbnail,
                    'json_data'  : MC.canvas.layout.save(),
                    'stack_id'   : MC.canvas_data.id
                },
                success : ( res ) ->
                    console.log 'phantom callback'
                    console.log res
                    console.log res.status
                    if res.status is 'success'
                        if res.thumbnail is 'true'
                            console.log 's3 url = ' + res.result
                        else
                            me.trigger 'SAVE_PNG_COMPLETE', res.result
                    else
                        #
            }

        isChanged : () ->
            #check if there are changes
            ori_data = MC.canvas_property.original_json
            new_data = JSON.stringify( MC.canvas_data )

            if ori_data != new_data
                return true
            else
                return false

        startApp : () ->
            me = this

            app_model.start { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
            app_model.once 'APP_START_RETURN', (result) ->
                console.log 'APP_START_RETURN'
                console.log result

                me.set 'is_pending', true
                me.handleRequest result, 'START_APP'

        stopApp : () ->
            me = this

            app_model.start { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
            app_model.once 'APP_STOP_RETURN', (result) ->
                console.log 'APP_STOP_RETURN'
                console.log result

                me.set 'is_pending', true
                me.handleRequest result, 'STOP_APP'

        terminateApp : () ->
            me = this

            #terminate : ( src, username, session_id, region_name, app_id, app_name=null )
            app_model.terminate { sender : this }, $.cookie( 'usercode' ), $( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
            app_model.once 'APP_TERMINATE_RETURN', (result) ->
                console.log 'APP_TERMINATE_RETURN'
                console.log result

                me.set 'is_pending', true
                me.handleRequest result, 'TERMINATE_APP'

        handleRequest : (result, flag) ->
            if !result.is_error
                if flag == 'RUN_STACK'
                    console.log 'run stack request successfully'
                    this.trigger 'TOOLBAR_STACK_RUN_REQUEST_SUCCESS'
                else if flag == 'START_APP'
                    console.log 'start app request successfully'
                    this.trigger 'TOOLBAR_APP_START_REQUEST_SUCCESS'
                else if flag == 'STOP_APP'
                    console.log 'stop app request successfully'
                    this.trigger 'TOOLBAR_APP_STOP_REQUEST_SUCCESS'
                else if flag == 'TERMINATE_APP'
                    console.log 'terminate app request successfully'
                    this.trigger 'TOOLBAR_APP_TERMINATE_SUCCESS'

                if ws
                    req_id = result.resolved_data.id
                    console.log 'request id:' + req_id
                    query = ws.collection.request.find({id:req_id})
                    handle = query.observeChanges {
                        changed : (id, req) ->
                            console.log 'stop handle'
                            handle.stop()
                            is_success = false

                            if req.state == "Done"
                                if flag == 'RUN_STACK'
                                    this.trigger 'TOOLBAR_STACK_RUN_SUCCESS'
                                else if flag == 'START_APP'
                                    this.trigger 'TOOLBAR_APP_START_SUCCESS'
                                else if flag == 'STOP_APP'
                                    this.trigger 'TOOLBAR_APP_STOP_SUCCESS'
                                else if flag == 'TERMINATE_APP'
                                    this.trigger 'TOOLBAR_APP_TERMINATE_SUCCESS'

                                is_success = true
                                #push event
                                ide_event.trigger ide_event.UPDATE_APP_LIST, null

                            else if req.state == "Failed"
                                if flag == 'RUN_STACK'
                                    this.trigger 'TOOLBAR_STACK_RUN_FAILED'
                                else if flag == 'START_APP'
                                    this.trigger 'TOOLBAR_APP_START_FAILED'
                                else if flag == 'STOP_APP'
                                    this.trigger 'TOOLBAR_APP_STOP_FAILED'
                                else if flag == 'TERMINATE_APP'
                                    this.trigger 'TOOLBAR_APP_TERMINATE_FAILED'

                            if flag is 'TERMINATE_APP' and is_success
                                ide_event.trigger ide_event.APP_TERMINATE, MC.canvas_data.name, MC.canvas_data.id
                            else
                                this.setFlag flag, is_success

                            ide_event.trigger ide_event.UPDATE_APP_LIST
                    }

            else
                if flag == 'RUN_STACK'
                    this.trigger 'TOOLBAR_STACK_RUN_REQUEST_FAILED'
                else if flag == 'START_APP'
                    this.trigger 'TOOLBAR_APP_START_REQUEST_FAILED'
                else if flag == 'STOP_APP'
                    this.trigger 'TOOLBAR_APP_STOP_REQUEST_FAILED'
                else if flag == 'TERMINATE_APP'
                    this.trigger 'TOOLBAR_APP_TERMINATE_REQUEST_FAILED'

            this.set 'is_pending', false

        isInstanceStore : () ->

            is_instance_store = false

            if 'component' in MC.canvas_data.layout and 'node' in MC.canvas_data.layout.component
                for node in MC.canvas_data.layout.component.node
                    if node.rootDeviceType == 'instance-store'
                        is_instance_store = true
                        break

            is_instance_store

    }

    model = new ToolbarModel()

    return model
