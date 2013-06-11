#*************************************************************************************
#* Filename     : log_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:03
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'log_service', 'log_vo'], ( Backbone, log_service, log_vo ) ->

    LogModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : log_vo.log
        }

        ###### api ######
        #put_user_log api (define function)
        put_user_log : ( src, username, session_id, user_logs ) ->

            me = this

            src.model = me

            log_service.put_user_log src, username, session_id, user_logs, ( forge_result ) ->

                if !forge_result.is_error
                #put_user_log succeed

                    log_info = forge_result.resolved_data

                    #set vo


                else
                #put_user_log failed

                    console.log 'log.put_user_log failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'LOG_PUT__USER__LOG_RETURN', forge_result



    }

    #############################################################
    #private (instantiation)
    log_model = new LogModel()

    #public (exposes methods)
    log_model

