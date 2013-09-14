#############################
#  View Mode for reset
#############################

define [ 'MC', 'event', 'account_model' ], ( MC, ide_event, account_model ) ->

    #private
    ReSetModel = Backbone.Model.extend {

        #defaults   :

        initialize : ->
            #

        resetPasswordServer : ( result ) ->
            console.log 'resetPasswordServer, result = ' + result
            #
            account_model.reset_password { sender : this }, result
            this.once 'ACCOUNT_RESET__PWD_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_RESET__PWD_RETURN'
                console.log forge_result
                if !forge_result.is_error
                    #
                    window.location.href = 'reset.html#email'
                else
                    #
                null

    }

    return new ReSetModel()