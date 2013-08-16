#*************************************************************************************
#* Filename     : request_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:03
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'request_service'], ( Backbone, request_service) ->

    RequestModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #init api (define function)
        init : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            request_service.init src, username, session_id, region_name, ( forge_result ) ->

                if !forge_result.is_error
                #init succeed

                    request_info = forge_result.resolved_data

                    #set vo


                else
                #init failed

                    console.log 'request.init failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'REQUEST_INIT_RETURN', forge_result


        #update api (define function)
        update : ( src, username, session_id, region_name, timestamp=null ) ->

            me = this

            src.model = me

            request_service.update src, username, session_id, region_name, timestamp, ( forge_result ) ->

                if !forge_result.is_error
                #update succeed

                    request_info = forge_result.resolved_data

                    #set vo


                else
                #update failed

                    console.log 'request.update failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'REQUEST_UPDATE_RETURN', forge_result



    }

    #############################################################
    #private (instantiation)
    request_model = new RequestModel()

    #public (exposes methods)
    request_model

