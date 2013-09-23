#############################
#  View Mode for reset
#############################

define [ 'MC', 'event', 'account_model' ], ( MC, ide_event, account_model ) ->

    #private
    ReSetModel = Backbone.Model.extend {

        defaults   :
        	key    : null

        initialize : ->
            this.on 'ACCOUNT_CHECK__REPEAT_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_CHECK__REPEAT_RETURN'
                console.log forge_result
                if !forge_result.is_error
                    this.trigger 'NO_EMAIL'
                else
                    #result = if forge_result.param[1] then forge_result.param[1] else forge_result.param[2]
                    @_resetPasswordServer if forge_result.param[1] then forge_result.param[1] else forge_result.param[2]
                null

        checkRepeatService : ( value ) ->
            console.log 'checkRepeatService, value = ' + value
            if /\w+@[0-9a-zA-Z_]+?\.[a-zA-Z]{2,6}/.test( value )
                username = null
                email    = value
            else
                username = value
                email    = null
            #
            account_model.check_repeat { sender : this }, username, email

        _resetPasswordServer : ( result ) ->
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