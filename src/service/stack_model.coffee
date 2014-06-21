#*************************************************************************************
#* Filename     : stack_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:42
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'stack_service', 'ami_service', 'base_model' ], ( Backbone, _, stack_service, ami_service, base_model ) ->

    StackModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #create api (define function)
        create : ( src, username, session_id, region_name, spec ) ->

            me = this

            src.model = me

            stack_service.create src, username, session_id, region_name, spec, ( forge_result ) ->

                if !forge_result.is_error
                #create succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_CREATE_RETURN', forge_result

                else
                #create failed

                    console.log 'stack.create failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #remove api (define function)
        remove : ( src, username, session_id, region_name, stack_id, stack_name=null ) ->

            me = this

            src.model = me

            stack_service.remove src, username, session_id, region_name, stack_id, stack_name, ( forge_result ) ->

                if !forge_result.is_error
                #remove succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_REMOVE_RETURN', forge_result

                else
                #remove failed

                    console.log 'stack.remove failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #save api (define function)
        save_stack : ( src, username, session_id, region_name, spec ) ->

            me = this

            src.model = me

            stack_service.save src, username, session_id, region_name, spec, ( forge_result ) ->

                if !forge_result.is_error
                #save succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_SAVE_RETURN', forge_result

                else
                #save failed

                    console.log 'stack.save failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #rename api (define function)
        rename : ( src, username, session_id, region_name, stack_id, new_name, stack_name=null ) ->

            me = this

            src.model = me

            stack_service.rename src, username, session_id, region_name, stack_id, new_name, stack_name, ( forge_result ) ->

                if !forge_result.is_error
                #rename succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_RENAME_RETURN', forge_result

                else
                #rename failed

                    console.log 'stack.rename failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #run api (define function)
        run : ( src, username, session_id, region_name, stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null, usage=null ) ->

            me = this

            src.model = me

            stack_service.run src, username, session_id, region_name, stack_id, app_name, app_desc, app_component, app_property, app_layout, stack_name, usage, ( forge_result ) ->

                if !forge_result.is_error
                #run succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_RUN_RETURN', forge_result

                else
                #run failed

                    console.log 'stack.run failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #save_as api (define function)
        save_as : ( src, username, session_id, region_name, stack_id, new_name, stack_name=null ) ->

            me = this

            src.model = me

            stack_service.save_as src, username, session_id, region_name, stack_id, new_name, stack_name, ( forge_result ) ->

                if !forge_result.is_error
                #save_as succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_SAVE__AS_RETURN', forge_result

                else
                #save_as failed

                    console.log 'stack.save_as failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #info api (define function)
        info : ( src, username, session_id, region_name, stack_ids=null ) ->

            me = this

            src.model = me

            stack_service.info src, username, session_id, region_name, stack_ids, ( forge_result ) ->

                if !forge_result.is_error
                #info succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_INFO_RETURN', forge_result

                else
                #info failed

                    console.log 'stack.info failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #list api (define function)
        list : ( src, username, session_id, region_name=null, stack_ids=null ) ->

            me = this

            src.model = me

            stack_service.list src, username, session_id, region_name, stack_ids, ( forge_result ) ->

                if !forge_result.is_error
                #list succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_LST_RETURN', forge_result

                else
                #list failed

                    console.log 'stack.list failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #export_cloudformation api (define function)
        export_cloudformation : ( src, username, session_id, region_name, stack ) ->

            me = this

            src.model = me

            stack_service.export_cloudformation src, username, session_id, region_name, stack, ( forge_result ) ->

                if !forge_result.is_error
                #export_cloudformation succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_EXPORT__CLOUDFORMATION_RETURN', forge_result

                else
                #export_cloudformation failed

                    console.log 'stack.export_cloudformation failed, error is ' + forge_result.error_message
                    me.pub forge_result


        get_not_exist_ami : ( src, username, session_id, region_name, ami_list ) ->

            me = this

            src.model = me

            ami_service.DescribeImages src, username, session_id, region_name, ami_list, null, null, null, ( result ) ->

                if !result.is_error
                    if src.sender and src.sender.trigger then src.sender.trigger 'GET_NOT_EXIST_AMI_RETURN', result
                else
                    console.log 'ami.DescribeImages failed, error is ' + result.error_message



        #verify api (define function)
        verify : ( src, username, session_id, spec ) ->

            me = this

            src.model = me

            stack_service.verify src, username, session_id, spec, ( forge_result ) ->

                if !forge_result.is_error
                #verify succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STACK_VERIFY_RETURN', forge_result

                else
                #verify failed

                    console.log 'stack.verify failed, error is ' + forge_result.error_message
                    me.pub forge_result



    }

    #############################################################
    #private (instantiation)
    stack_model = new StackModel()

    #public (exposes methods)
    stack_model
