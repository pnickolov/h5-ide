#*************************************************************************************
#* Filename     : state_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-12-11 11:19:25
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'state_service', 'base_model' ], ( Backbone, _, state_service, base_model ) ->

    StateModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #module api (define function)
        module : ( src, username, session_id, mod_repo, mod_tag ) ->

            me = this

            src.model = me

            state_service.module src, username, session_id, mod_repo, mod_tag, ( forge_result ) ->

                if !forge_result.is_error
                #module succeed

                    if forge_result.resolved_data

                        jsonDataStr = forge_result.resolved_data

                        try
                            jsonData = JSON.parse(jsonDataStr)
                            forge_result.resolved_data = jsonData
                            if src.sender and src.sender.trigger then src.sender.trigger 'STATE_MODULE_RETURN', forge_result, src
                            return

                        catch err
                            console.log 'state.module failed, error is JSON parse error'

                console.log 'state.module failed, error is ' + forge_result.error_message
                me.pub forge_result

        #status api (define function)
        status : ( src, username, session_id, app_id ) ->

            me = this

            src.model = me

            state_service.status src, username, session_id, app_id, ( forge_result ) ->

                if !forge_result.is_error
                #status succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STATE_STATUS_RETURN', forge_result

                else
                #status failed

                    console.log 'state.status failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #log api (define function)
        log : ( src, username, session_id, app_id, res_id=null ) ->

            me = this

            src.model = me

            state_service.log src, username, session_id, app_id, res_id, ( forge_result ) ->

                if !forge_result.is_error
                #log succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'STATE_LOG_RETURN', forge_result

                else
                #log failed

                    console.log 'state.log failed, error is ' + forge_result.error_message
                    me.pub forge_result




    }

    #############################################################
    #private (instantiation)
    state_model = new StateModel()

    #public (exposes methods)
    state_model

