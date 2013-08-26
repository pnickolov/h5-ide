#*************************************************************************************
#* Filename     : guest_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:41
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'guest_service', 'base_model' ], ( Backbone, _, guest_service, base_model ) ->

    GuestModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #invite api (define function)
        invite : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            guest_service.invite src, username, session_id, region_name, ( forge_result ) ->

                if !forge_result.is_error
                #invite succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'GUEST_INVITE_RETURN', forge_result

                else
                #invite failed

                    console.log 'guest.invite failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #cancel api (define function)
        cancel : ( src, username, session_id, region_name, guest_id ) ->

            me = this

            src.model = me

            guest_service.cancel src, username, session_id, region_name, guest_id, ( forge_result ) ->

                if !forge_result.is_error
                #cancel succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'GUEST_CANCEL_RETURN', forge_result

                else
                #cancel failed

                    console.log 'guest.cancel failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #access api (define function)
        access : ( src, guestname, session_id, region_name, guest_id ) ->

            me = this

            src.model = me

            guest_service.access src, guestname, session_id, region_name, guest_id, ( forge_result ) ->

                if !forge_result.is_error
                #access succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'GUEST_ACCESS_RETURN', forge_result

                else
                #access failed

                    console.log 'guest.access failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #end api (define function)
        end : ( src, guestname, session_id, region_name, guest_id ) ->

            me = this

            src.model = me

            guest_service.end src, guestname, session_id, region_name, guest_id, ( forge_result ) ->

                if !forge_result.is_error
                #end succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'GUEST_END_RETURN', forge_result

                else
                #end failed

                    console.log 'guest.end failed, error is ' + forge_result.error_message
                    me.pub forge_result



        #info api (define function)
        info : ( src, username, session_id, region_name, guest_id=null ) ->

            me = this

            src.model = me

            guest_service.info src, username, session_id, region_name, guest_id, ( forge_result ) ->

                if !forge_result.is_error
                #info succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'GUEST_INFO_RETURN', forge_result

                else
                #info failed

                    console.log 'guest.info failed, error is ' + forge_result.error_message
                    me.pub forge_result




    }

    #############################################################
    #private (instantiation)
    guest_model = new GuestModel()

    #public (exposes methods)
    guest_model

