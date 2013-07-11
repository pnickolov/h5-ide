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

            #MC.canvas_data.region = 'ap-southeast-1'
            #MC.canvas_data.id = 'stack-401ef6cd'
            #MC.canvas_data.name = 'stack_test_save-copy'

            stack_model.save { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data

            stack_model.once 'STACK_SAVE_RETURN', (result) ->
                console.log 'STACK_SAVE_RETURN'
                console.log result

                if !result.is_error
                    console.log 'send save stack successful message'

                    ide_event.trigger ide_event.UPDATE_STACK_LIST

        #duplicate
        duplicateStack : () ->
            me = this

            #MC.canvas_data.id = 'stack-7ed0d670'
            #MC.canvas_data.name = 'stack_test_save'
            #MC.canvas_data.region = 'ap-southeast-1'

            new_name = MC.canvas_data.name + '-copy'
            stack_model.save_as { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, new_name, MC.canvas_data.name
            stack_model.once 'STACK_SAVE__AS_RETURN', (result) ->
                console.log 'STACK_SAVE__AS_RETURN'
                console.log result

                if !result.is_error
                    console.log 'send save as stack successful message'

                    #load the new copy stack
                    ide_event.trigger ide_event.OPEN_STACK_TAB, new_name, MC.canvas_data.region, result.resolved_data

                    #update stack list
                    ide_event.trigger ide_event.UPDATE_STACK_LIST

        #delete
        deleteStack : () ->
            me = this

            #MC.canvas_data.id = 'stack-50e101a2'
            #MC.canvas_data.region = 'ap-southeast-1'
            #MC.canvas_data.name = MC.canvas_data.name + '-copy'

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

            #src, username, session_id, region_name, stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null
            stack_model.run { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data.id, app_name
            stack_model.once 'STACK_RUN_RETURN', (result) ->
                console.log 'STACK_RUN_RETURN'
                console.log resutl

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

    }

    model = new ToolbarModel()

    return model
