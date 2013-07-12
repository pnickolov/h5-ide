#############################
#  View Mode for design/toolbar module
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'stack_model', 'constant' ], (MC, Backbone, $, _, ide_event, stack_model, constant) ->

    #private
    ToolbarModel = Backbone.Model.extend {

        defaults :
            'zoomin_flag'   : true
            'zoomout_flag'  : true

        #save stack
        saveStack : () ->
            me = this

            ##if there is no change, not save
            name = MC.canvas_data.name
            if not name
                console.log 'remind user no stack name'
            else
                id = MC.canvas_data.id
                if id   #save
                    stack_model.save { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data

                    stack_model.once 'STACK_SAVE_RETURN', (result) ->
                        console.log 'STACK_SAVE_RETURN'
                        console.log result

                        if !result.is_error
                            console.log 'save stack successfully'

                            ##update initial data

                            me.trigger 'TOOLBAR_STACK_READY'

                            ide_event.trigger ide_event.UPDATE_STACK_LIST

                            #call save png
                            me.savePNG true

                else    #new
                    stack_model.create { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data

                    stack_model.once 'STACK_CREATE_RETURN', (result) ->
                        console.log 'STACK_CREATE_RETURN'
                        console.log result

                        if !result.is_error
                            console.log 'create stack successfully'

                            ##update initial data

                            MC.canvas_data.id = result.resolved_data

                            me.trigger 'TOOLBAR_STACK_READY'

                            ide_event.trigger ide_event.UPDATE_STACK_LIST

                            #call save png
                            me.savePNG true

        #duplicate
        duplicateStack : () ->
            me = this

            ##if there is changes, first remind user to save
            new_name = MC.canvas_data.name + '-copy'
            region = MC.canvas_data.region
            #check name
            if new_name in MC.data.stack_list[region]
                console.log 'remind user the repeated stack name'
            else
                stack_model.save_as { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, MC.canvas_data.id, new_name, MC.canvas_data.name
                stack_model.once 'STACK_SAVE__AS_RETURN', (result) ->
                    console.log 'STACK_SAVE__AS_RETURN'
                    console.log result

                    if !result.is_error
                        console.log 'save as stack successfully'

                        #update stack list
                        ide_event.trigger ide_event.UPDATE_STACK_LIST

        #delete
        deleteStack : () ->
            me = this

            stack_model.remove { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
            stack_model.once 'STACK_REMOVE_RETURN', (result) ->
                console.log 'STACK_REMOVE_RETURN'
                console.log result

                if !result.is_error
                    console.log 'send delete stack successful message'

                    #trigger event
                    ide_event.trigger ide_event.STACK_DELETE, MC.canvas_data.name, MC.canvas_data.id

        #run
        runStack : ( app_name ) ->
            me = this

            stack_model.run { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, app_name
            stack_model.once 'STACK_RUN_RETURN', (result) ->
                console.log 'STACK_RUN_RETURN'
                console.log result

                if !result.is_error
                    console.log 'send run stack successful message'

        #zoomin
        zoomInStack : () ->
            me = this

            MC.canvas.zoomIn()

            zoomin_flag = true
            if MC.canvas_property.SCALE_RATIO <= 1
                zoomin_flag = false

            me.set 'zoomin_flag', zoomin_flag

            null

        #zoomout
        zoomOutStack : () ->
            me = this

            MC.canvas.zoomOut()

            zoomout_flag = true
            if MC.canvas_property.SCALE_RATIO >= 1.8
                zoomout_flag = false

            me.set 'zoomout_flag', zoomout_flag

            null

        savePNG : ( is_thumbnail ) ->
            console.log 'savePNG'
            me = this
            #
            $.ajax {
                url  : 'http://localhost:3001/savepng',
                type : 'post',
                data : {
                    'usercode'   : $.cookie( 'usercode' ),
                    'session_id' : $.cookie( 'session_id' ),
                    'region'     : MC.canvas_data.region,
                    'stack_id'   : MC.canvas_data.id,
                    'thumbnail'  : is_thumbnail,
                    'screenshot' : 'http://localhost:3000/screenshot.html'
                },
                success : ( result ) ->
                    console.log 'phantom callback'
                    console.log result
                    if result.status is 'success'
                        #
                    else
                        #
            }

    }

    model = new ToolbarModel()

    return model
