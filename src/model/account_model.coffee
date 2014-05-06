#*************************************************************************************
#* Filename     : account_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-09-13 09:03:17
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'account_service', 'base_model' ], ( Backbone, _, account_service, base_model ) ->

    AccountModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #update_account api (define function)
        update_account : ( src, username, session_id, attributes ) ->

            me = this

            src.model = me

            account_service.update_account src, username, session_id, attributes, ( forge_result ) ->

                if !forge_result.is_error
                #update_account succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ACCOUNT_UPDATE__ACCOUNT_RETURN', forge_result

                else
                #update_account failed

                    console.log 'account.update_account failed, error is ' + forge_result.error_message
                    if src.sender and src.sender.trigger then src.sender.trigger 'ACCOUNT_UPDATE__ACCOUNT_RETURN', forge_result


        #reset_key api (define function)
        reset_key : ( src, username, session_id, flag ) ->

            me = this

            src.model = me

            account_service.reset_key src, username, session_id, flag, ( forge_result ) ->

                if !forge_result.is_error
                #reset_key succeed

                else
                #reset_key failed

                    console.log 'account.reset_key failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'ACCOUNT_RESET__KEY_RETURN', forge_result

    }

    #############################################################
    #private (instantiation)
    account_model = new AccountModel()

    #public (exposes methods)
    account_model

