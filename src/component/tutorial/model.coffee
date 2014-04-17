#############################
#  View Mode for component/tutorial
#############################

define [ 'account_model', 'backbone', 'jquery', 'underscore', 'MC' ], ( account_model ) ->

    TutorialModel = Backbone.Model.extend {

        initialize : ->
            me = this

            #####listen ACCOUNT_UPDATE__ACCOUNT_RETURN
            me.on 'ACCOUNT_UPDATE__ACCOUNT_RETURN', (result) ->
                console.log 'ACCOUNT_UPDATE__ACCOUNT_RETURN'

                attributes = result.param[3]

                if !result.is_error

                    if attributes.state is '2'
                        #
                        MC.common.cookie.setCookieByName 'state', attributes.state
                else


                null

        updateAccountService : ->
            console.log 'updateAccountService'
            account_model.update_account {sender:this}, $.cookie('usercode'), $.cookie('session_id'), { 'state' : '2' }

    }

    return TutorialModel
