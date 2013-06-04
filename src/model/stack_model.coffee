#*************************************************************************************
#* Filename     : stack_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 13:50:55
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'stack_service', 'stack_vo'], ( Backbone, stack_service, stack_vo ) ->

    StackModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : stack_vo.stack
        }

        ###### api ######
        #create api (define function)
        create : ( username, session_id, region_name, spec ) ->

            me = this

            stack_service.create username, password, ( forge_result ) ->

                if !forge_result.is_error
                #create succeed

                    stack_info = forge_result.resolved_data

                    #set vo


                else
                #create failed

                    console.log 'stack.create failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'STACK_CREATE_RETURN', forge_result


        #remove api (define function)
        remove : ( username, session_id, region_name, stack_id, stack_name=null ) ->

            me = this

            stack_service.remove username, password, ( forge_result ) ->

                if !forge_result.is_error
                #remove succeed

                    stack_info = forge_result.resolved_data

                    #set vo


                else
                #remove failed

                    console.log 'stack.remove failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'STACK_REMOVE_RETURN', forge_result


        #save api (define function)
        save : ( username, session_id, region_name, spec ) ->

            me = this

            stack_service.save username, password, ( forge_result ) ->

                if !forge_result.is_error
                #save succeed

                    stack_info = forge_result.resolved_data

                    #set vo


                else
                #save failed

                    console.log 'stack.save failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'STACK_SAVE_RETURN', forge_result


        #rename api (define function)
        rename : ( username, session_id, region_name, stack_id, new_name, stack_name=null ) ->

            me = this

            stack_service.rename username, password, ( forge_result ) ->

                if !forge_result.is_error
                #rename succeed

                    stack_info = forge_result.resolved_data

                    #set vo


                else
                #rename failed

                    console.log 'stack.rename failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'STACK_RENAME_RETURN', forge_result


        #run api (define function)
        run : ( username, session_id, region_name, stack_id, app_name, app_desc=null, app_component=null, app_property=null, app_layout=null, stack_name=null ) ->

            me = this

            stack_service.run username, password, ( forge_result ) ->

                if !forge_result.is_error
                #run succeed

                    stack_info = forge_result.resolved_data

                    #set vo


                else
                #run failed

                    console.log 'stack.run failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'STACK_RUN_RETURN', forge_result


        #save_as api (define function)
        save_as : ( username, session_id, region_name, stack_id, new_name, stack_name=null ) ->

            me = this

            stack_service.save_as username, password, ( forge_result ) ->

                if !forge_result.is_error
                #save_as succeed

                    stack_info = forge_result.resolved_data

                    #set vo


                else
                #save_as failed

                    console.log 'stack.save_as failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'STACK_SAVE__AS_RETURN', forge_result


        #info api (define function)
        info : ( username, session_id, region_name, stack_ids=null ) ->

            me = this

            stack_service.info username, password, ( forge_result ) ->

                if !forge_result.is_error
                #info succeed

                    stack_info = forge_result.resolved_data

                    #set vo


                else
                #info failed

                    console.log 'stack.info failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'STACK_INFO_RETURN', forge_result


        #list api (define function)
        list : ( username, session_id, region_name, stack_ids=null ) ->

            me = this

            stack_service.list username, password, ( forge_result ) ->

                if !forge_result.is_error
                #list succeed

                    stack_info = forge_result.resolved_data

                    #set vo


                else
                #list failed

                    console.log 'stack.list failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'STACK_LST_RETURN', forge_result



    }

    #############################################################
    #private (instantiation)
    stack_model = new StackModel()

    #public (exposes methods)
    stack_model

