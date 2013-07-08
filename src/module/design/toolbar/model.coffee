#############################
#  View Mode for design/toolbar module
#############################

define [ 'MC', 'backbone', 'jquery', 'underscore', 'event', 'stack_model', 'constant' ], (MC, Backbone, $, _, ide_event, stack_model, constant) ->

    #private
    ToolbarModel = Backbone.Model.extend {

        #save stack
        save_stack : () ->
            me = this

            stack_model.save { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data

            stack_model.once 'STACK_SAVE_RETURN' (result) ->
                console.log 'STACK_SAVE_RETURN'
                console.log result

                if !result.is_error
                    console.log 'send save stack successful message'

        #duplicate
        duplicate_stack : ( stack_id, new_name, stack_name=null ) ->
            me = this

            stack_model.save_as { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, stack_id, new_name, stack_name
            stack_model.once 'STACK_SAVE__AS_RETURN' (result) ->
                console.log 'STACK_SAVE__AS_RETURN'
                console.log result

                if !result.is_error
                    console.log 'send save as stack successful message'

        #delete
        delete_stack : ( stack_id, stack_name=null ) ->
            me = this

            #src, username, session_id, region_name, stack_id, stack_name=null
            stack_model.remove { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, stack_id, stack_name
            stack_model.once 'STACK_REMOVE_RETURN' (result) ->
                console.log 'STACK_REMOVE_RETURN'
                console.log result

                if !result.is_error
                    console.log 'send delete stack successful message'

        #new
        new_stack : () ->
            me = this

            stack_model.create { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, MC.canvas_data
            stack_model.once 'STACK_CREATE_RETURN' (result) ->
                console.log 'STACK_CREATE_RETURN'
                console.log resutl

                if !result.is_error
                    console.log 'send new stack successful message'

        #run
        run_stack : ( stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null ) ->
            me = this
            #src, username, session_id, region_name, stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null
            stack_model.run { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, stack_id, app_name, app_desc, app_component, app_property, app_layout, stack_name
            stack_model.once 'STACK_RUN_RETURN' (result) ->
                console.log 'STACK_RUN_RETURN'
                console.log resutl

                if !result.is_error
                    console.log 'send run stack successful message'

    }

    model = new ToolbarModel()

    return model
