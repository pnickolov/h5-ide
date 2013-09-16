#############################
#  View Mode for reset
#############################

define [ 'MC', 'event', 'account_model' ], ( MC, ide_event, account_model ) ->

    #private
    ReSetModel = Backbone.Model.extend {

        defaults   :
        	key : null

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
                    this.trigger 'NO_EMAIL'
                null

        updatePasswordServer : ( result ) ->
            console.log 'updatePasswordServer, result = ' + result + ', key = ' + this.get( 'key' )
            #
            account_model.update_password { sender : this }, this.get( 'key' ), result
            this.once 'ACCOUNT_UPDATE__PWD_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_UPDATE__PWD_RETURN'
                console.log forge_result
                if !forge_result.is_error
                    #
                    window.location.href = 'reset.html#success'
                else
                    this.trigger 'PASSWORD_INVAILD'
                null

    }

    return new ReSetModel()