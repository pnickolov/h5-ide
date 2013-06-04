#*************************************************************************************
#* Filename     : guest_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 15:26:55
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'guest_service', 'guest_vo'], ( Backbone, guest_service, guest_vo ) ->

    GuestModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : guest_vo.guest
        }

        ###### api ######
        #invite api (define function)
        invite : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            guest_service.invite src, username, session_id, region_name, ( forge_result ) ->

                if !forge_result.is_error
                #invite succeed

                    guest_info = forge_result.resolved_data

                    #set vo


                else
                #invite failed

                    console.log 'guest.invite failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'GUEST_INVITE_RETURN', forge_result


        #cancel api (define function)
        cancel : ( src, username, session_id, region_name, guest_id ) ->

            me = this

            src.model = me

            guest_service.cancel src, username, session_id, region_name, guest_id, ( forge_result ) ->

                if !forge_result.is_error
                #cancel succeed

                    guest_info = forge_result.resolved_data

                    #set vo


                else
                #cancel failed

                    console.log 'guest.cancel failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'GUEST_CANCEL_RETURN', forge_result


        #access api (define function)
        access : ( src, guestname, session_id, region_name, guest_id ) ->

            me = this

            src.model = me

            guest_service.access src, guestname, session_id, region_name, guest_id, ( forge_result ) ->

                if !forge_result.is_error
                #access succeed

                    guest_info = forge_result.resolved_data

                    #set vo


                else
                #access failed

                    console.log 'guest.access failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'GUEST_ACCESS_RETURN', forge_result


        #end api (define function)
        end : ( src, guestname, session_id, region_name, guest_id ) ->

            me = this

            src.model = me

            guest_service.end src, guestname, session_id, region_name, guest_id, ( forge_result ) ->

                if !forge_result.is_error
                #end succeed

                    guest_info = forge_result.resolved_data

                    #set vo


                else
                #end failed

                    console.log 'guest.end failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'GUEST_END_RETURN', forge_result


        #info api (define function)
        info : ( src, username, session_id, region_name, guest_id=null ) ->

            me = this

            src.model = me

            guest_service.info src, username, session_id, region_name, guest_id=null, ( forge_result ) ->

                if !forge_result.is_error
                #info succeed

                    guest_info = forge_result.resolved_data

                    #set vo


                else
                #info failed

                    console.log 'guest.info failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'GUEST_INFO_RETURN', forge_result



    }

    #############################################################
    #private (instantiation)
    guest_model = new GuestModel()

    #public (exposes methods)
    guest_model

