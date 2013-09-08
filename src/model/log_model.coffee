#*************************************************************************************
#* Filename     : log_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:40
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'log_service', 'base_model' ], ( Backbone, _, log_service, base_model ) ->

    LogModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #put_user_log api (define function)
        put_user_log : ( src, username, session_id, user_logs ) ->

            me = this

            src.model = me

            log_service.put_user_log src, username, session_id, user_logs, ( forge_result ) ->

                if !forge_result.is_error
                #put_user_log succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'LOG_PUT__USER__LOG_RETURN', forge_result

                else
                #put_user_log failed

                    console.log 'log.put_user_log failed, error is ' + forge_result.error_message
                    me.pub forge_result




    }

    #############################################################
    #private (instantiation)
    log_model = new LogModel()

    #public (exposes methods)
    log_model

