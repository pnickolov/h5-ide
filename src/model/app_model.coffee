#*************************************************************************************
#* Filename     : app_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 13:50:53
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'app_service', 'app_vo'], ( Backbone, app_service, app_vo ) ->

    AppModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : app_vo.app
        }

        ###### api ######
        #create api (define function)
        create : ( username, session_id, region_name, spec ) ->

            me = this

            app_service.create username, password, ( forge_result ) ->

                if !forge_result.is_error
                #create succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #create failed

                    console.log 'app.create failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_CREATE_RETURN', forge_result


        #update api (define function)
        update : ( username, session_id, region_name, spec, app_id ) ->

            me = this

            app_service.update username, password, ( forge_result ) ->

                if !forge_result.is_error
                #update succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #update failed

                    console.log 'app.update failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_UPDATE_RETURN', forge_result


        #rename api (define function)
        rename : ( username, session_id, region_name, app_id, new_name, app_name=null ) ->

            me = this

            app_service.rename username, password, ( forge_result ) ->

                if !forge_result.is_error
                #rename succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #rename failed

                    console.log 'app.rename failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_RENAME_RETURN', forge_result


        #terminate api (define function)
        terminate : ( username, session_id, region_name, app_id, app_name=null ) ->

            me = this

            app_service.terminate username, password, ( forge_result ) ->

                if !forge_result.is_error
                #terminate succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #terminate failed

                    console.log 'app.terminate failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_TERMINATE_RETURN', forge_result


        #start api (define function)
        start : ( username, session_id, region_name, app_id, app_name=null ) ->

            me = this

            app_service.start username, password, ( forge_result ) ->

                if !forge_result.is_error
                #start succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #start failed

                    console.log 'app.start failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_START_RETURN', forge_result


        #stop api (define function)
        stop : ( username, session_id, region_name, app_id, app_name=null ) ->

            me = this

            app_service.stop username, password, ( forge_result ) ->

                if !forge_result.is_error
                #stop succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #stop failed

                    console.log 'app.stop failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_STOP_RETURN', forge_result


        #reboot api (define function)
        reboot : ( username, session_id, region_name, app_id, app_name=null ) ->

            me = this

            app_service.reboot username, password, ( forge_result ) ->

                if !forge_result.is_error
                #reboot succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #reboot failed

                    console.log 'app.reboot failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_REBOOT_RETURN', forge_result


        #info api (define function)
        info : ( username, session_id, region_name, app_ids=null ) ->

            me = this

            app_service.info username, password, ( forge_result ) ->

                if !forge_result.is_error
                #info succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #info failed

                    console.log 'app.info failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_INFO_RETURN', forge_result


        #list api (define function)
        list : ( username, session_id, region_name, app_ids=null ) ->

            me = this

            app_service.list username, password, ( forge_result ) ->

                if !forge_result.is_error
                #list succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #list failed

                    console.log 'app.list failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_LST_RETURN', forge_result


        #resource api (define function)
        resource : ( username, session_id, region_name, app_id ) ->

            me = this

            app_service.resource username, password, ( forge_result ) ->

                if !forge_result.is_error
                #resource succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #resource failed

                    console.log 'app.resource failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_RESOURCE_RETURN', forge_result


        #summary api (define function)
        summary : ( username, session_id, region_name=null ) ->

            me = this

            app_service.summary username, password, ( forge_result ) ->

                if !forge_result.is_error
                #summary succeed

                    app_info = forge_result.resolved_data

                    #set vo


                else
                #summary failed

                    console.log 'app.summary failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'APP_SUMMARY_RETURN', forge_result



    }

    #############################################################
    #private (instantiation)
    app_model = new AppModel()

    #public (exposes methods)
    app_model

