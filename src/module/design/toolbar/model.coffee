#############################
#  View Mode for design/toolbar module
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'stack_model', 'constant' ], (MC, Backbone, $, _, ide_event, stack_model, constant) ->

    #websocket
    ws = MC.data.websocket

    #private
    ToolbarModel = Backbone.Model.extend {

        defaults :
            'toolbar_flag'  : null
            'stack_name'    : null

        setFlag : (type, value) ->
            me = this

            #set stack name
            if MC.canvas_data.name
                me.set 'stack_name', MC.canvas_data.name

            toolbar_flag_list = me.get 'toolbar_flag'
            if not toolbar_flag_list
                toolbar_flag_list = { 'duplicate' : false, 'delete' : false, 'zoomin' : true, 'zoomout' : true }

            if type is 'NEW_STACK'
                toolbar_flag_list.duplicate  = false
                toolbar_flag_list.delete     = false
            else if type is 'OPEN_STACK'
                toolbar_flag_list.duplicate  = true
                toolbar_flag_list.delete     = true
            else if type is 'SAVE_STACK'
                toolbar_flag_list.duplicate  = true
                toolbar_flag_list.delete     = true
            else if type is 'ZOOMIN_STACK'
                toolbar_flag_list.zoomin     = value
            else if type is 'ZOOMOUT_STACK'
                toolbar_flag_list.zoomout    = value

            me.set 'toolbar_flag', toolbar_flag_list
            me.trigger 'UPDATE_TOOLBAR'

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
                        me.trigger 'TOOLBAR_STACK_SAVE_ERROR'

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
                        me.trigger 'TOOLBAR_STACK_SAVE_ERROR'

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
                    me.trigger 'TOOLBAR_STACK_DUPLICATE_ERROR'

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
                    me.trigger 'TOOLBAR_STACK_DELETE_ERROR'

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

                if !result.is_error
                    console.log 'run stack request successful'
                    me.trigger 'TOOLBAR_STACK_RUN_REQUEST_SUCCESS'

                    if ws
                        req_id = result.resolved_data.id
                        console.log "request id:" + req_id
                        query = ws.collection.request.find({id:req_id})
                        handle = query.observeChanges {
                            changed : (id, req) ->
                                if req.state == "Done"
                                    handle.stop()
                                    console.log 'stop handle'

                                    #update app name list
                                    if app_name not in MC.data.app_list[MC.canvas_data.region]
                                        MC.data.app_list[MC.canvas_data.region].push app_name

                                    #push event
                                    ide_event.trigger ide_event.UPDATE_APP_LIST, null
                                    this.trigger 'TOOLBAR_STACK_RUN_SUCCESS'
                                else if req.state == "Failed"
                                    handle.stop()
                                    console.log 'stop handle'

                                    this.trigger 'TOOLBAR_STACK_RUN_FAILED'
                        }
                    null

                else
                    me.trigger 'TOOLBAR_STACK_RUN_REQUEST_ERROR'

        #zoomin
        zoomInStack : () ->
            me = this

            MC.canvas.zoomIn()

            zoomin_flag = true
            if MC.canvas_property.SCALE_RATIO <= 1
                zoomin_flag = false

            me.setFlag('ZOOMIN_STACK', zoomin_flag)

            null

        #zoomout
        zoomOutStack : () ->
            me = this

            MC.canvas.zoomOut()

            zoomout_flag = true
            if MC.canvas_property.SCALE_RATIO >= 1.8
                zoomout_flag = false

            me.setFlag('ZOOMOUT_STACK', zoomout_flag)

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

    }

    model = new ToolbarModel()

    return model
