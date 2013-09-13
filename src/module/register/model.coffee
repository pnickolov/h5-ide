#############################
#  View Mode for register
#############################

define [ 'MC', 'event', 'account_model' ], ( MC, ide_event, account_model ) ->

    #private
    RegisterModel = Backbone.Model.extend {

        #defaults   :

        initialize : ->
            #

        checkRepeatService : ( username, email, password ) ->
            console.log 'checkRepeatService, username = ' + username + ', email = ' + email + ', password = ' + password
            #
            account_model.check_repeat { sender : this }, username, email
            this.once 'ACCOUNT_CHECK__REPEAT_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_CHECK__REPEAT_RETURN'
                console.log forge_result
                if !forge_result.is_error
                    @registerService username, email, password
                else
                    if forge_result.error_message is 'Repeated username, please choose another one'
                        this.trigger 'USERNAME_REPEAT'
                    if forge_result.error_message is "TypeError: Cannot call method 'toString' of undefined"
                    	@registerService username, email, password
                null

        registerService : ( username, email, password ) ->
            console.log 'registerService, username = ' + username, + ', email = ' + email + ', password = ' + password
            #
            account_model.register { sender : this }, username, password, email
            this.once 'ACCOUNT_REGISTER_RETURN', ( forge_result ) ->
                console.log 'ACCOUNT_REGISTER_RETURN'
                console.log forge_result
                if !forge_result.is_error
                    window.location.href = 'register.html#success'
                else
                    #
               	null


    }

    return new RegisterModel()