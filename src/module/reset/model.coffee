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

        checkKeyServer : () ->
            console.log 'checkKeyServer, key = ' + this.get( 'key' )
            #
            account_model.check_validation { sender : this }, this.get( 'key' ), 'reset'
            this.once 'ACCOUNT_CHECK__VALIDATION_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_CHECK__VALIDATION_RETURN'
                console.log forge_result
                if !forge_result.is_error
                    #
                    this.trigger 'KEY_VALID'
                else
                    #
                    window.location.href = 'reset.html#expire'
                null

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
                    #this.trigger 'PASSWORD_INVAILD'
                    #window.location.href = 'reset.html#expire' if forge_result.return_code is 2
                null

    }

    return new ReSetModel()