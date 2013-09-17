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
        #register api (define function)
        register : ( src, username, password, email ) ->

            me = this

            src.model = me

            account_service.register src, username, password, email, ( forge_result ) ->

                if !forge_result.is_error
                #register succeed

                else
                #register failed

                    console.log 'account.register failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'ACCOUNT_REGISTER_RETURN', forge_result

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



        #reset_password api (define function)
        reset_password : ( src, username ) ->

            me = this

            src.model = me

            account_service.reset_password src, username, ( forge_result ) ->

                if !forge_result.is_error
                #reset_password succeed

                else
                #reset_password failed

                    console.log 'account.reset_password failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'ACCOUNT_RESET__PWD_RETURN', forge_result



        #update_password api (define function)
        update_password : ( src, id, new_pwd ) ->

            me = this

            src.model = me

            account_service.update_password src, id, new_pwd, ( forge_result ) ->

                if !forge_result.is_error
                #update_password succeed

                else
                #update_password failed

                    console.log 'account.update_password failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'ACCOUNT_UPDATE__PWD_RETURN', forge_result



        #check_repeat api (define function)
        check_repeat : ( src, username, email ) ->

            me = this

            src.model = me

            account_service.check_repeat src, username, email, ( forge_result ) ->

                if !forge_result.is_error
                #check_repeat succeed

                else
                #check_repeat failed

                    console.log 'account.check_repeat failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'ACCOUNT_CHECK__REPEAT_RETURN', forge_result

        #check_validation api (define function)
        check_validation : ( src, key, flag ) ->

            me = this

            src.model = me

            account_service.check_validation src, key, flag, ( forge_result ) ->

                if !forge_result.is_error
                #check_validation succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ACCOUNT_CHECK__VALIDATION_RETURN', forge_result

                else
                #check_validation failed

                    console.log 'account.check_validation failed, error is ' + forge_result.error_message
                    me.pub forge_result




    }

    #############################################################
    #private (instantiation)
    account_model = new AccountModel()

    #public (exposes methods)
    account_model

